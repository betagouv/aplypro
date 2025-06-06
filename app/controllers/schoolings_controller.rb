# frozen_string_literal: true

class SchoolingsController < ApplicationController
  include RoleCheck

  before_action :authenticate_user!, :set_classe, :set_schooling
  before_action :check_director, :update_confirmed_director!, :check_confirmed_director,
                only: %i[abrogate_decision update]
  before_action :set_student_breadcrumbs, only: %i[confirm_removal
                                                   confirm_removal_cancellation
                                                   confirm_da_extension
                                                   confirm_cancellation_decision
                                                   confirm_abrogation]

  def create_attributive_decision
    @schooling.update(generating_attributive_decision: true)

    Generate::AttributiveDecisionJob.perform_later(@schooling)

    redirect_to student_path(@schooling.student), notice: t("flash.da.create", name: @schooling.student.full_name)
  end

  def abrogate_decision
    Generate::AbrogationDecisionJob.perform_now(@schooling)

    retry_incomplete_payment_request!

    redirect_to student_path(@schooling.student), notice: t("flash.da.abrogated", name: @schooling.student.full_name)
  end

  def confirm_abrogation; end

  def cancellation_decision
    Generate::CancellationDecisionJob.perform_now(@schooling)

    redirect_to student_path(@schooling.student), notice: t("flash.da.cancellation", name: @schooling.student.full_name)
  end

  def confirm_cancellation_decision; end

  def confirm_da_extension; end

  def confirm_removal; end

  def confirm_removal_cancellation; end

  def remove
    @schooling.remove!(params[:removed_at])

    redirect_to school_year_class_path(selected_school_year, @classe), notice: t("flash.schooling.#{params[:notice]}",
                                                                                 name: @schooling.student,
                                                                                 classe: @schooling.classe.label)
  end

  def update # rubocop:disable Metrics/AbcSize
    extended_end_date = schooling_params[:extended_end_date]

    if extended_end_date.present? && @schooling.any_extended_pfmp?(Date.parse(extended_end_date))
      redirect_to request.referer, alert: t("flash.da.cant_remove_extension", name: @schooling.student.full_name)
    else
      @schooling.update(extended_end_date: extended_end_date)

      redirect_to student_path(@schooling.student),
                  notice: t(extended_end_date.blank? ? "flash.da.extension_removed" : "flash.da.extended",
                            name: @schooling.student.full_name)
    end
  end

  private

  def set_schooling
    @schooling = Schooling.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year), alert: t("errors.schoolings.not_found")
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
      payment_request.mark_ready! if payment_request&.eligible_for_incomplete_auto_retry?
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
