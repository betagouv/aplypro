# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student

  def show
    @schoolings = @student.schoolings

    infer_page_title(name: @student.full_name)
  end

  private

  def set_student
    @student = Student.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @student.any_classes_in_establishment?(current_establishment)

    @student
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year), alert: t("errors.students.not_found")
  end
end
