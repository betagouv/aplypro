# frozen_string_literal: true

class ValidationsController < ApplicationController
  include RoleCheck

  before_action :set_classe, only: %i[show validate]
  before_action :check_director, only: %i[show validate]
  before_action :update_confirmed_director!,
                :check_confirmed_director_for_validation,
                only: :validate

  # Display overview of classes that require validation and failed payments that require attention
  def index
    infer_page_title

    @validations_facade = ValidationsFacade.new(current_establishment)

    @validatable_classes = @validations_facade.validatable_classes
    @classes_facade = @validations_facade.classes_facade
  end

  def show
    add_breadcrumb t("pages.titles.validations.index"), validations_path
    infer_page_title(name: @classe.label)

    @pfmps = current_establishment.validatable_pfmps
                                  .includes(schooling: :attributive_decision_attachment)
                                  .where(schoolings: { classe: @classe })
                                  .includes(student: :rib)
                                  .order(:"students.last_name", :"pfmps.start_date")

    @total_amount = @pfmps.sum(:amount)
  end

  # Validate all Pfmps for a given classe
  def validate
    if validation_params.empty?
      redirect_to validation_class_path(@classe), alert: t("validations.create.empty") and return
    end

    current_establishment.validatable_pfmps
                         .where(id: validation_params[:pfmp_ids], schoolings: { classe: @classe })
                         .find_each { |pfmp| pfmp.transition_to!(:validated) }

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
    @classe = current_estabishment.classes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to validations_path, alert: t("errors.classes.not_found") and return
  end

  def validation_params
    params.require(:validation).permit(pfmp_ids: [])
  rescue ActionController::ParameterMissing
    {}
  end
end
