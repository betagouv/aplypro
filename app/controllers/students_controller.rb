# frozen_string_literal: true

class StudentsController < ClassesController
  before_action :set_student

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb @classe.to_s, class_path(@classe)

    infer_page_title(name: @student.full_name, classe: @classe)
  end

  private

  def set_student
    @student = @classe.students.find_by(ine: params[:id])
  end

  def set_classe
    @classe = Classe.find_by(id: params[:class_id])
  end
end
