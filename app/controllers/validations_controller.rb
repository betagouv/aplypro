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

    @validations_facade = ValidationsFacade.new(current_establishment, selected_school_year)

    @validatable_classes = @validations_facade.validatable_classes
    @classes_facade = @validations_facade.classes_facade
  end

  def show
    add_breadcrumb t("pages.titles.validations.index"), school_year_validations_path(selected_school_year)
    infer_page_title(name: @classe.label)

    @pfmps = current_establishment.validatable_pfmps
                                  .includes(schooling: :attributive_decision_attachment)
                                  .where(schoolings: { classe: @classe })
                                  .includes(student: :ribs)
                                  .order(:"students.last_name", :"pfmps.start_date")

    @total_amount = @pfmps.sum(:amount)
  end

  # Validate all Pfmps for a given classe
  # rubocop:disable Metrics/AbcSize
  def validate
    if validation_params.empty?
      redirect_to validation_school_year_class_path(selected_school_year, @classe),
                  alert: t("validations.create.empty") and return
    end

    current_establishment.validatable_pfmps
                         .where(id: validation_params[:pfmp_ids], schoolings: { classe: @classe })
                         .find_each { |pfmp| pfmp.transition_to!(:validated) }

    redirect_to school_year_validations_path(selected_school_year),
                notice: t("validations.create.success", classe_label: @classe.label)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def check_confirmed_director_for_validation
    check_confirmed_director(
      alert_message: t("validations.create.not_director"),
      redirect_path: validation_school_year_class_path(selected_school_year, @classe)
    )
  end

  def set_classe
    @classe = current_establishment.classes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_validations_path(selected_school_year),
                alert: t("errors.classes.not_found") and return
  end

  def validation_params
    params.require(:validation).permit(pfmp_ids: [])
  rescue ActionController::ParameterMissing
    {}
  end
end
