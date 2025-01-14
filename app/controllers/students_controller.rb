# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, :check_student!, only: :show
  before_action :sanitize_search, :set_search_result, only: :search_results

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_class

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
    return if @name.nil?

    search_pattern = Regexp.new(@name, "i")
    @students = current_establishment.students
                                     .where("unaccent(last_name) ~* ? OR unaccent(first_name) ~* ? OR " \
                                            "unaccent(concat(first_name, ' ', last_name)) ~* ? OR " \
                                            "unaccent(concat(last_name, ' ', first_name)) ~* ?",
                                            search_pattern, search_pattern, search_pattern, search_pattern)
                                     .distinct
  end

  def sanitize_search
    @name = params[:name].strip
    @name = nil if @name.empty?
  end
end
