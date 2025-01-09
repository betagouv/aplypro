# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :sanitize_search,
                :set_students_result

  def search_student
    if @students.blank?
      redirect_to request.referer, alert: t("errors.search.students.not_found", search: @search) and return
    elsif @students.count > 1
      redirect_to request.referer, alert: t("errors.search.students.not_unique", search: @search) and return
    end

    redirect_to student_path(@students.first)
  end

  private

  def set_students_result # rubocop:disable Metrics/AbcSize
    return if @search.blank?

    @students = []
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
