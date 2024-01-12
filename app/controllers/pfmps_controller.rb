# frozen_string_literal: true

class PfmpsController < ApplicationController
  include RoleCheck

  before_action :authenticate_user!
  before_action :check_director, only: :validate
  before_action :set_classe, :set_student, :set_breadcrumbs
  before_action :set_pfmp, only: %i[show edit update validate confirm_deletion destroy]

  def show
    infer_page_title({ name: @student.full_name })
  end

  def new
    infer_page_title

    @inhibit_title = true

    @pfmp = Pfmp.new
  end

  def edit
    infer_page_title(name: @student.full_name)
  end

  def create
    @pfmp = Pfmp.new(pfmp_params.merge(schooling: @student.current_schooling))

    if @pfmp.save
      redirect_to class_student_path(@classe, @student), notice: t("pfmps.new.success")
    else
      @page_title = t("pages.titles.pfmps.new")
      @inhibit_title = true
      add_breadcrumb(t("pages.titles.pfmps.new"))

      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @pfmp.update(pfmp_params)
      redirect_to class_student_path(@classe, @student), notice: t("pfmps.edit.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def validate
    @pfmp.transition_to!(:validated)

    redirect_back_or_to class_student_pfmp_path(@classe, @student, @pfmp),
                        notice: t("flash.pfmps.validated", name: @student.full_name)
  end

  def confirm_deletion
    redirect_to class_student_path(@classe, @student) and return if @pfmp.nil?

    add_breadcrumb(
      t("pages.titles.pfmps.show", name: @student.full_name),
      class_student_pfmp_path(@classe, @student, @pfmp)
    )

    infer_page_title
  end

  def destroy
    @pfmp.destroy

    redirect_to class_student_path(@classe, @student), notice: t("flash.pfmps.destroyed", name: @student.full_name)
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date,
      :day_count
    )
  end

  def set_pfmp
    @pfmp = @student.pfmps.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to class_student_path(@classe, @student), alert: t("errors.pfmps.not_found") and return
  end

  def set_student
    @student = @classe.students.find(params[:student_id])
  end

  def set_classe
    @classe = Classe.where(establishment: @etab).find(params[:class_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end

  def set_breadcrumbs
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)
    add_breadcrumb(
      t("pages.titles.students.show", name: @student.full_name, classe: @classe.label),
      class_student_path(@classe, @student)
    )
  end
end
