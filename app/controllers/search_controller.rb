class SearchController < ApplicationController

  before_action :sanitize_search,
                :set_student_result,

  def search_student
    redirect_to student_path(@student)
  end

  private

  def set_student_result
    return if @search.blank?

    # TODO: Gérer les noms de famille + les retours multiples
    #Student.find_by("first_name LIKE ? AND last_name LIKE ?","#{params[:first_name]}%", "#{params[:last_name]}%")
    @student = Student.find_by("first_name LIKE ?", "%#{@search}%")
  end

  def sanitize_search
    return if params[:search].blank?

    @search = params[:search].strip.capitalize
  end
end
