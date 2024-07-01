# frozen_string_literal: true

module PfmpResource
  extend ActiveSupport::Concern

  def set_pfmp
    @pfmp = @schooling.student.pfmps.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to class_student_path(@classe, @schooling.student), alert: t("errors.pfmps.not_found") and return
  end

  def set_schooling
    @schooling = @classe.schoolings.find(params[:schooling_id])
  end

  def set_classe
    @classe = current_establishment.classes.find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end

  def set_student_breadcrumbs
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)
    add_breadcrumb(
      t("pages.titles.students.show", name: @schooling.student.full_name, classe: @classe.label),
      class_student_path(@classe, @schooling.student)
    )
  end

  def set_pfmp_breadcrumbs
    set_student_breadcrumbs
    infer_page_title(name: @schooling.student.full_name)
  end
end
