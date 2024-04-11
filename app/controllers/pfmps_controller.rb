# frozen_string_literal: true

class PfmpsController < ApplicationController
  include RoleCheck

  before_action :check_director, :update_confirmed_director!, :check_confirmed_director, only: :validate

  before_action :set_classe, :set_schooling
  before_action :set_pfmp_breadcrumbs, except: :confirm_deletion
  before_action :set_pfmp, only: %i[show edit update validate confirm_deletion destroy reset_payment_request]

  def show; end

  def new
    @pfmp = Pfmp.new
  end

  def edit; end

  def create
    @pfmp = Pfmp.new(pfmp_params.merge(schooling: @schooling))

    if @pfmp.save
      redirect_to class_student_path(@classe, @schooling.student), notice: t("pfmps.new.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @pfmp.update(pfmp_params)
      redirect_to class_schooling_pfmp_path(@classe, @schooling, @pfmp), notice: t("pfmps.edit.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def validate
    @pfmp.validate!

    redirect_back_or_to class_schooling_pfmp_path(@classe, @schooling, @pfmp),
                        notice: t("flash.pfmps.validated", name: @schooling.student.full_name)
  end

  def reset_payment_request
    @pfmp.payment_requests.create!

    redirect_back_or_to class_schooling_pfmp_path(@classe, @schooling, @pfmp),
                        notice: t("flash.pfmps.reset_payment_request", name: @schooling.student.full_name)
  end

  def confirm_deletion
    set_student_breadcrumbs
    add_breadcrumb(
      t("pages.titles.pfmps.show", name: @schooling.student.full_name),
      class_schooling_pfmp_path(@classe, @schooling, @pfmp)
    )
    infer_page_title

    redirect_to class_student_path(@classe, @schooling.student) and return if @pfmp.nil?
  end

  def destroy
    @pfmp.destroy

    redirect_to class_student_path(@classe, @schooling.student),
                notice: t("flash.pfmps.destroyed", name: @schooling.student.full_name)
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
    @pfmp = @schooling.student.pfmps.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to class_student_path(@classe, @schooling.student), alert: t("errors.pfmps.not_found") and return
  end

  def set_schooling
    @schooling = @classe.schoolings.find(params[:schooling_id])
  end

  def set_classe
    @classe = Classe.where(establishment: current_establishment).find(params[:class_id])
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
