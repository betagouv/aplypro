# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, :check_student!, only: :show

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_class

  before_action :set_search_result, only: :search_results

  def show
    @schoolings = @student.schoolings

    infer_page_title(name: @student.full_name)
  end

  def search_results
    infer_page_title
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def check_student!
    raise ActiveRecord::RecordNotFound unless @student.any_classes_in_establishment?(current_establishment)
  end

  def redirect_to_class
    redirect_to school_year_classes_path(selected_school_year), alert: t("errors.students.not_found")
  end

  def set_search_result
    @name = params[:name]

    @students = current_establishment.find_students(@name)
                                     .page(params[:page])
                                     .per(50)
  end
end
