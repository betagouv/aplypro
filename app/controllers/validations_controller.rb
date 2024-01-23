# frozen_string_literal: true

class ValidationsController < ApplicationController
  include RoleCheck

  before_action :set_classe, only: %i[show validate]
  before_action :check_director, only: %i[index show validate]
  before_action :update_confirmed_director!,
                :check_confirmed_director_for_validation,
                :check_empty_params,
                only: :validate

  def index
    infer_page_title

    @classes_pfmps_counts = validatable_pfmps.group(:classe_id).count
    @classes = Classe.where(id: @classes_pfmps_counts.keys)

    fetch_classes_indicators(@classes)
  end

  def show
    add_breadcrumb t("pages.titles.validations.index"), validations_path
    infer_page_title(name: @classe.label)

    @pfmps = validatable_pfmps
             .where(schoolings: { classe: @classe })
             .joins(:mef)
             .merge(Mef.with_wages)
             .joins(:student)
             .order(:"students.last_name", :"pfmps.start_date")

    @total_amount = @pfmps.map(&:calculate_amount).sum
  end

  def validate
    validatable_pfmps
      .where(schoolings: { classe: @classe })
      .where(id: validation_params[:pfmp_ids])
      .find_each do |pfmp|
        pfmp.transition_to!(:validated)
      end

    redirect_to validations_path, notice: t("validations.create.success", classe_label: @classe.label)
  end

  private

  def check_confirmed_director_for_validation
    check_confirmed_director(
      alert_message: t("validations.create.not_director"),
      redirect_path: validation_class_path(@classe)
    )
  end

  def set_classe
    @classe = Classe.where(establishment: current_establishment).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to validations_path, alert: t("errors.classes.not_found") and return
  end

  def validatable_pfmps
    current_establishment.active_pfmps.in_state(:completed)
  end

  def validation_params
    params.require(:validation).permit(pfmp_ids: [])
  end

  def check_empty_params
    return if params[:validation].present? && validation_params[:pfmp_ids].present?

    redirect_to validation_class_path(@classe), alert: t("validations.create.empty") and return
  end
end
