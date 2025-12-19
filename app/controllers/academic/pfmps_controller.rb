# frozen_string_literal: true

module Academic
  class PfmpsController < Academic::ApplicationController
    skip_before_action :infer_page_title, only: :show
    before_action :set_student_and_pfmp, only: :show

    def show
      infer_page_title(id: @pfmp.id, name: @student.full_name)
    end

    private

    def set_student_and_pfmp
      @student = Student.joins(schoolings: :establishment)
                        .where(establishments: { academy_code: selected_academy })
                        .distinct
                        .find(params[:student_id])

      @pfmp = @student.pfmps.find(params[:id])
    end
  end
end
