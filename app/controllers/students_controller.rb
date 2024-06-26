# frozen_string_literal: true

class StudentsController < ClassesController
  before_action :set_classe, :set_student

  def show
    add_breadcrumb t("pages.titles.classes.index"), school_year_classes_path(selected_school_year.start_year)
    add_breadcrumb @classe.to_s, school_year_class_path(selected_school_year.start_year, @classe)
    @pfmps = @student.pfmps.joins(:classe).where(schooling: { classe: @classe })

    infer_page_title(name: @student.full_name, classe: @classe)
  end

  private

  def set_student
    @student = @classe.students.includes(:rib, :pfmps).find(params[:id])
    @schooling = @classe.schooling_of(@student)
  rescue ActiveRecord::RecordNotFound
    redirect_to @classe, alert: t("errors.students.not_found")
  end

  def set_classe
    @classe = Classe
              .where(establishment: current_establishment)
              .find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year.start_year),
                alert: t("errors.classes.not_found") and return
  end
end
