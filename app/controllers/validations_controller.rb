# frozen_string_literal: true

class ValidationsController < ApplicationController
  include RoleCheck

  before_action :set_classe, only: %i[show validate]
  before_action :check_director, only: %i[index show validate]
  before_action :update_confirmed_director!,
                :check_confirmed_director_for_validation,
                only: :validate

  # Display classes that require validation
  # rubocop:disable Layout/LineLength
  def index
    infer_page_title

    @rejected_pfmps = current_establishment
      .pfmps
      .in_state(:validated)
      .joins(:payment_requests)
      .joins("INNER JOIN asp_payment_request_transitions ON asp_payment_requests.id = asp_payment_request_transitions.asp_payment_request_id")
      .where(asp_payment_request_transitions: { to_state: ASP::PaymentRequestStateMachine::FAILED_STATES,
                                                most_recent: true })

    @classes = Classe.where(id: validatable_pfmps.distinct.pluck(:"classes.id"))
    @classes_facade = ClassesFacade.new(@classes)
  end
  # rubocop:enable Layout/LineLength

  def show
    add_breadcrumb t("pages.titles.validations.index"), validations_path
    infer_page_title(name: @classe.label)

    @pfmps = validatable_pfmps
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
    validatable_pfmps_ids = current_establishment.pfmps.in_state(:completed).select do |pfmp|
      pfmp.can_transition_to?(:validated)
    end.map(&:id)
    current_establishment.pfmps.where(id: validatable_pfmps_ids)
  end

  def validation_params
    params.require(:validation).permit(pfmp_ids: [])
  rescue ActionController::ParameterMissing
    {}
  end
end
