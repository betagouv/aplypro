# frozen_string_literal: true

class PfmpsController < ApplicationController
  before_action :authenticate_principal!

  before_action :set_classe, :set_student, :set_breadcrumbs, only: %i[new create edit show update]
  before_action :set_pfmp, only: %i[show edit update validate]

  def index
    infer_page_title

    @pfmps = Pfmp
             .includes(:student, :payments, :transitions, classe: [:mef])
             .where(classe: { establishment: @etab })
             .group_by(&:current_state)
  end

  def show
    infer_page_title({ name: @student.full_name })
  end

  def validate_all
    add_breadcrumb t("pages.titles.pfmps.index"), pfmps_path

    infer_page_title

    @pfmps = Pfmp
             .in_state(:completed)
             .includes(:student, classe: :mef)
             .where(classe: { establishment: @etab })

    @pfmp = @pfmps.first
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

    respond_to do |format|
      if @pfmp.save
        format.html { redirect_to class_student_path(@classe, @student), notice: t("pfmps.new.success") }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pfmp.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @pfmp.update(pfmp_params)
        format.html { redirect_to class_student_path(@classe, @student), notice: t("pfmps.edit.success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def validate
    add_breadcrumb t("pages.titles.pfmps.index"), pfmps_path
    add_breadcrumb t("pages.titles.pfmps.validate")

    @pfmp = Pfmp.find(params[:pfmp_id])

    @pfmp.transition_to!(:validated)

    redirect_back_or_to validate_all_pfmps_path, notice: "La PFMP de #{@pfmp.student} a bien été validée"
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
    @pfmp = Pfmp.find_by(id: params[:id])
  end

  def set_student
    @student = @classe.students.find_by(ine: params[:student_id])
  end

  def set_classe
    @classe = Classe.find_by(id: params[:class_id])
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
