# frozen_string_literal: true

module Academic
  class StudentsController < Academic::ApplicationController
    skip_before_action :infer_page_title, only: :show
    before_action :set_student, only: :show
    before_action :set_search_result, only: :search_results

    helper_method :current_establishment

    VALID_SORT_OPTIONS = %w[name establishment].freeze
    STUDENTS_PER_PAGE = 50

    def show
      @schoolings = @student.schoolings.includes(
        :pfmps,
        :attributive_decision_attachment,
        :abrogation_decision_attachment,
        :cancellation_decision_attachment,
        classe: [:establishment, :school_year]
      )

      infer_page_title(name: @student.full_name)
    end

    def search_results
      infer_page_title
    end

    private

    def current_establishment
      @current_establishment ||= @student.current_schooling&.establishment
    end

    def set_student
      @student = Student.joins(schoolings: :establishment)
                        .where(establishments: { academy_code: selected_academy })
                        .distinct
                        .find(params[:id])
    end

    def set_search_result
      @name = params[:name]
      @students = find_and_sort_students
                  .page(params[:page])
                  .per(STUDENTS_PER_PAGE)
    end

    def find_and_sort_students
      students = Establishment.find_students(academy_establishments, @name)

      sort_column == "establishment" ? sort_by_establishment(students) : sort_by_name(students)
    end

    def sort_by_establishment(students)
      students.joins(<<~SQL.squish)
        LEFT JOIN schoolings current_sch
          ON current_sch.student_id = students.id
          AND current_sch.end_date IS NULL
        LEFT JOIN classes
          ON classes.id = current_sch.classe_id
        LEFT JOIN establishments
          ON establishments.id = classes.establishment_id
      SQL
              .order(Arel.sql("establishments.name ASC NULLS LAST"))
              .order("students.last_name ASC, students.first_name ASC")
    end

    def sort_by_name(students)
      students.order("students.last_name ASC, students.first_name ASC")
    end

    def sort_column
      VALID_SORT_OPTIONS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def academy_establishments
      Establishment.joins(:classes)
                   .where(academy_code: selected_academy,
                          "classes.school_year_id": selected_school_year)
    end
  end
end
