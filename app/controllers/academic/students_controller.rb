# frozen_string_literal: true

module Academic
  class StudentsController < Academic::ApplicationController
    before_action :set_student, only: :show

    before_action :set_search_result, only: :search_results

    helper_method :current_establishment

    def show
      @schoolings = @student.schoolings

      infer_page_title(name: @student.full_name)
    end

    def search_results
      infer_page_title
    end

    private

    def current_establishment
      @current_establishment ||= @student.current_schooling.establishment
    end

    def set_student
      @student = Student.find(params[:id])
    end

    def set_search_result
      @name = params[:name]

      @students = Establishment.find_students(academy_establishments, @name)
    end

    def academy_establishments
      Establishment.joins(:classes)
                   .where(academy_code: selected_academy,
                          "classes.school_year_id": selected_school_year)
    end
  end
end
