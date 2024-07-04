# frozen_string_literal: true

class PfmpsController < ApplicationController
  include RoleCheck
  include PfmpResource

  before_action :check_director, :update_confirmed_director!, :check_confirmed_director,
                only: %i[validate]

  before_action :set_classe, :set_schooling
  before_action :set_pfmp_breadcrumbs, except: :confirm_deletion
  before_action :set_pfmp, except: %i[new create]

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
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year.start_year, @classe, @schooling, @pfmp),
                  notice: t("pfmps.edit.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def validate
    @pfmp.validate!

    redirect_back_or_to school_year_class_schooling_pfmp_path(selected_school_year.start_year,
                                                              @classe,
                                                              @schooling,
                                                              @pfmp),
                        notice: t("flash.pfmps.validated", name: @schooling.student.full_name)
  end

  def confirm_deletion
    set_student_breadcrumbs
    add_breadcrumb(
      t("pages.titles.pfmps.show", name: @schooling.student.full_name),
      school_year_class_schooling_pfmp_path(selected_school_year.start_year, @classe, @schooling, @pfmp)
    )
    infer_page_title

    redirect_to class_student_path(@classe, @schooling.student) and return if @pfmp.nil?
  end

  def destroy
    if @pfmp.destroy
      redirect_to class_student_path(@classe, @schooling.student),
                  notice: t("flash.pfmps.destroyed", name: @schooling.student.full_name)
    else
      redirect_to class_student_path(@classe, @schooling.student),
                  alert: t("flash.pfmps.not_destroyed")
    end
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date,
      :day_count
    )
  end
end
