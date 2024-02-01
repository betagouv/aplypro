# frozen_string_literal: true

class ValidationsController < ApplicationController
  include RoleCheck

  before_action :set_classe, only: %i[show validate]
  before_action :check_director, only: %i[index show validate]
  before_action :update_confirmed_director!,
                :check_confirmed_director_for_validation,
                only: :validate

  def index
    infer_page_title

    @classes = Classe.where(id: validatable_pfmps.distinct.pluck(:"classes.id"))
    @classes_facade = ClassesFacade.new(@classes)
  end

  def show
    add_breadcrumb t("pages.titles.validations.index"), validations_path
    infer_page_title(name: @classe.label)

    @pfmps = validatable_pfmps
             .includes(schooling: :attributive_decision_attachment)
             .where(schoolings: { classe: @classe })
             .joins(:mef)
             .merge(Mef.with_wages)
             .includes(student: :rib)
             .order(:"students.last_name", :"pfmps.start_date")

    @total_amount = @pfmps.map(&:calculate_amount).sum
  end

  def validate
    if validation_params.empty?
      redirect_to validation_class_path(@classe), alert: t("validations.create.empty") and return
    end

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
    current_establishment.pfmps.in_state(:completed)
  end

  def validation_params
    params.require(:validation).permit(pfmp_ids: [])
  rescue ActionController::ParameterMissing
    {}
  end
end
