# frozen_string_literal: true

class StudentsController < ClassesController
  before_action :set_classe, :set_student

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb @classe.to_s, class_path(@classe)

    infer_page_title(name: @student.full_name, classe: @classe)
  end

  private

  def set_student
    @student = @classe.students.includes(:rib, :pfmps).find_by(ine: params[:id])
  end

  def set_classe
    @classe = Classe
              .where(establishment: @etab)
              .find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end
end
