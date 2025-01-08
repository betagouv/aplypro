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

  def set_students_result
    return if @search.blank?

    @students = []
    Student.find_each do |student|
      first_name = student.first_name.upcase
      last_name = student.last_name.upcase
      full_name1 = student.full_name.upcase
      full_name2 = (last_name + first_name).upcase

      if first_name.include?(@search) ||
         last_name.include?(@search) ||
         full_name1.include?(@search) ||
         full_name2.include?(@search)
        @students << student
      end
    end
  end

  def sanitize_search
    return if params[:search].blank?

    @search = params[:search].upcase
  end
end
