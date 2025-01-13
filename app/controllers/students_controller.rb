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

  # rubocop:disable Layout/LineLength
  def set_search_result
    search_str = "%#{@search}%"
    @students = current_establishment.students.where(
      "
        TRANSLATE(TRANSLATE(UNACCENT(last_name), $$',$$, ''), '-', ' ') ILIKE TRANSLATE(TRANSLATE(UNACCENT(:search_str), $$',$$, ''), '-', ' ') OR
        TRANSLATE(TRANSLATE(UNACCENT(first_name), $$',$$, ''), '-', ' ') ILIKE TRANSLATE(TRANSLATE(UNACCENT(:search_str), $$',$$, ''), '-', ' ') OR
        TRANSLATE(TRANSLATE(UNACCENT(CONCAT(last_name, ' ', first_name)), $$',$$, ''), '-', ' ') ILIKE TRANSLATE(TRANSLATE(UNACCENT(:search_str), $$',$$, ''), '-', ' ') OR
        TRANSLATE(TRANSLATE(UNACCENT(CONCAT(first_name, ' ', last_name)), $$',$$, ''), '-', ' ') ILIKE TRANSLATE(TRANSLATE(UNACCENT(:search_str), $$',$$, ''), '-', ' ')
      ", search_str:
    ).uniq
    # Dans l'idéal, utiliser la REGEX '%' :
    # TRANSLATE(UNACCENT(last_name), $$-', $$, $$%$$) ILIKE TRANSLATE(UNACCENT(:search_str), $$-', $$, $$%$$) OR
    # TRANSLATE(UNACCENT(first_name), $$-', $$, $$%$$) ILIKE TRANSLATE(UNACCENT(:search_str), $$-', $$, $$%$$) OR
    # TRANSLATE(UNACCENT(CONCAT(last_name, '%', first_name)), $$-', $$, $$%$$) ILIKE TRANSLATE(UNACCENT(:search_str), $$-', $$, $$%$$) OR
    # TRANSLATE(UNACCENT(CONCAT(first_name, '%', last_name)), $$-', $$, $$%$$) ILIKE TRANSLATE(UNACCENT(:search_str), $$-', $$, $$%$$)
  end
  # rubocop:enable Layout/LineLength

  def sanitize_search
    return if params[:search].blank?

    @search = params[:search]
  end
end
