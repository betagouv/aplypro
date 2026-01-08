# frozen_string_literal: true

module Academic
  class ClassesController < Academic::ApplicationController
    before_action :set_classe, only: :show

    def index
      infer_page_title

      @establishment = Establishment.joins(:classes)
                                    .where(academy_code: selected_academy,
                                           "classes.school_year_id": selected_school_year)
                                    .find(params[:establishment_id])

      @classes = @establishment.classes
                               .where(school_year: selected_school_year)
                               .includes(:mef, :school_year)
                               .left_joins(:active_schoolings)
                               .select("classes.*, COUNT(schoolings.id) AS active_students_count")
                               .group("classes.id")
                               .order(:label)
    end

    def show
      infer_page_title(name: @classe)

      @schoolings = @classe.schoolings.includes(
        :student,
        :attributive_decision_attachment
      ).order("students.last_name, students.first_name")
    end

    private

    def set_classe
      @classe = Classe.joins(:establishment)
                      .where(establishments: { academy_code: selected_academy },
                             school_year_id: selected_school_year)
                      .find(params[:id])
    end
  end
end
