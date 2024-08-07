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

  def confirm_da_extension;
    add_breadcrumb t("pages.titles.students.show", name: @schooling.student.full_name), school_year_class_path(selected_school_year, @classe)
    infer_page_title(name: t("pages.titles.schoolings.confirm_da_extension"))
  end

  def extend_da;
    @schooling.update!(extended_end_date: params[:extended_end_date])

    redirect_to school_year_class_path(selected_school_year, @classe),
                notice: t("flash.da.extended", name: @schooling.student.full_name)
  end

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

  def retry_eligibile_payment_requests!
    @schooling.pfmps.in_state(:validated).each do |pfmp|
      payment_request = pfmp.latest_payment_request
      payment_request.mark_ready! if payment_request&.eligible_for_auto_retry?
    end
  end
end
