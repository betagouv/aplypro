# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, :check_student!, only: :show
  before_action :sanitize_search, :set_search_result, only: :search

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_class

  def show
    @schoolings = @student.schoolings

    infer_page_title(name: @student.full_name)
  end

  def search
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

  def set_search_result # rubocop:disable Metrics/AbcSize
    @students = []

    return if @search.blank?

    current_establishment.students.each do |student|
      first_name = unify(student.first_name)
      last_name = unify(student.last_name)
      full_name1 = unify(student.full_name)
      full_name2 = unify(last_name + first_name)

      next unless first_name.include?(@search) ||
                  last_name.include?(@search) ||
                  full_name1.include?(@search) ||
                  full_name2.include?(@search)

      @students << student
    end
  end

  def sanitize_search
    return if params[:search].blank?

    @search = unify(params[:search])
  end

  def unify(string)
    I18n.transliterate(string.tr("-", " ").upcase, locale: :fr)
  end
end
