# frozen_string_literal: true

class StudentsController < ClassesController
  include RoleCheck

  before_action :set_classe, :set_student
  before_action :check_director, only: %i[abrogate_decision]

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb @classe.to_s, class_path(@classe)
    @pfmps = @student.pfmps.joins(:classe).where(schooling: { classe: @classe })

    infer_page_title(name: @student.full_name, classe: @classe)
  end

  def abrogate_decision
    GenerateAbrogationDecisionJob.perform_now(@schooling)

    redirect_to class_student_path(@classe, @student), notice: t("flash.da.abrogated", name: @student.full_name)
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
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end
end
