# frozen_string_literal: true

class SchoolingsController < ApplicationController
  include RoleCheck

  before_action :set_schooling, only: [:update]
  before_action :authenticate_user!, :set_classe, :set_schooling
  before_action :check_director, :update_confirmed_director!, :check_confirmed_director,
                only: %i[abrogate_decision update]
  before_action :set_student_breadcrumbs, only: %i[confirm_removal confirm_removal_cancellation confirm_da_extension]

  def abrogate_decision
    GenerateAbrogationDecisionJob.perform_now(@schooling)

    retry_incomplete_payment_request!

    redirect_to student_path(@schooling.student),
                notice: t("flash.da.abrogated", name: @schooling.student.full_name)
  end

  def confirm_abrogation; end

  def confirm_da_extension; end

  def confirm_removal; end

  def confirm_removal_cancellation; end

  def remove
    @schooling.update(removed_at: params[:value])

    redirect_to school_year_class_path(selected_school_year, @classe),
                notice: t("flash.schooling.removed", name: @schooling.student, classe: @schooling.classe.label)
  end

  def update # rubocop:disable Metrics/AbcSize
    extended_end_date = schooling_params[:extended_end_date]
    if extended_end_date.blank? && any_extended_pfmp?
      redirect_to school_year_class_path(selected_school_year, @classe),
                  alert: t("flash.da.cant_remove_extension", name: @schooling.student.full_name)
    elsif @schooling.update(extended_end_date: extended_end_date)
      redirect_to school_year_class_path(selected_school_year, @classe),
                  notice: t(extended_end_date.blank? ? "flash.da.extension_removed" : "flash.da.extended",
                            name: @schooling.student.full_name)
    else
      @schooling.extended_end_date = nil
      render :confirm_da_extension, status: :unprocessable_entity
    end
  end

  private

  def set_schooling
    @schooling = Schooling.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to @classe, alert: t("errors.schoolings.not_found")
  end

  def schooling_params
    params.require(:schooling).permit(:extended_end_date)
  end

  def set_classe
    @classe = Classe
              .where(establishment: current_establishment)
              .find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year),
                alert: t("errors.classes.not_found") and return
  end

  def retry_incomplete_payment_request!
    @schooling.pfmps.in_state(:validated).each do |pfmp|
      payment_request = pfmp.latest_payment_request
      payment_request.mark_ready! if payment_request&.eligible_for_auto_retry?
    end
  end

  def any_extended_pfmp?
    @schooling.pfmps.any? do |pfmp|
      pfmp.end_date > @schooling.end_date
    end
  end

  def set_student_breadcrumbs
    student = @schooling.student
    add_breadcrumb(
      t("pages.titles.students.show", name: student.full_name),
      student_path(student)
    )
    infer_page_title(name: student.full_name)
  end
end
