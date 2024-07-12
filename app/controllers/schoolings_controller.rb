# frozen_string_literal: true

class SchoolingsController < ApplicationController
  include RoleCheck

  before_action :authenticate_user!, :set_classe, :set_schooling
  before_action :check_director, :update_confirmed_director!, :check_confirmed_director, only: %i[abrogate_decision]

  def abrogate_decision
    GenerateAbrogationDecisionJob.perform_now(@schooling)

    retry_eligibile_payment_requests!

    redirect_to student_path(@schooling.student),
                notice: t("flash.da.abrogated", name: @schooling.student.full_name)
  end

  def confirm_abrogation; end

  private

  def set_schooling
    @schooling = Schooling.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to @classe, alert: t("errors.schoolings.not_found")
  end

  def set_classe
    @classe = Classe
              .where(establishment: current_establishment)
              .find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year),
                alert: t("errors.classes.not_found") and return
  end

  # Les requetes bloquées pour da non abrogée doivent être relancées automatiquement
  def retry_eligibile_payment_requests!
    Pfmp.find_by(schooling: @schooling) do |pfmp|
      if pfmp.latest_payment_request.in_state?(:incomplete)
        pfmp.latest_payment_request.mark_ready!
      end
    end
  end
end
