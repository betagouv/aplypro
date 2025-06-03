# frozen_string_literal: true

module Academic
  class StudentsController < Academic::ApplicationController
    before_action :set_student, :check_student!, only: :show

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

    def set_search_result
      @name = params[:name]

      @students = current_establishment.find_students(@name)
    end
  end
end
