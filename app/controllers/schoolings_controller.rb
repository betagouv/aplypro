# frozen_string_literal: true

class SchoolingsController < ApplicationController
  include RoleCheck

  before_action :authenticate_user!, :set_classe, :set_schooling
  before_action :check_director, only: %i[abrogate_decision]

  def abrogate_decision
    GenerateAbrogationDecisionJob.perform_now(@schooling)

    redirect_to class_student_path(@classe, @schooling.student),
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
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end
end
