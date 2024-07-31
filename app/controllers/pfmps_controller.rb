# frozen_string_literal: true

class PfmpsController < ApplicationController
  include RoleCheck
  include PfmpResource

  before_action :check_director, :update_confirmed_director!, :check_confirmed_director,
                only: %i[validate rectify]

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
      redirect_to student_path(@schooling.student),
                  notice: t("pfmps.new.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @pfmp.update(pfmp_params)
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  notice: t("pfmps.edit.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def validate
    @pfmp.validate!

    redirect_back_or_to school_year_class_schooling_pfmp_path(selected_school_year,
                                                              @classe,
                                                              @schooling,
                                                              @pfmp),
                        notice: t("flash.pfmps.validated", name: @schooling.student.full_name)
  end

  def confirm_deletion
    set_student_breadcrumbs
    add_breadcrumb(
      t("pages.titles.pfmps.show", name: @schooling.student.full_name),
      school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp)
    )
    infer_page_title

    return unless @pfmp.nil?

    redirect_to student_path(@schooling.student)
  end

  def confirm_rectification
    if @pfmp.can_transition_to?(:rectified)
      @student = @pfmp.student
      render :confirm_rectification
    else
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  alert: t("flash.pfmps.cannot_rectify")
    end
  end

  # TODO: maybe put this logic in PfmpManager
  def rectify # rubocop:disable Metrics/AbcSize
    if @pfmp.can_transition_to?(:rectified)
      ActiveRecord::Base.transaction do
        @pfmp.transition_to!(:rectified)
        @pfmp.update(day_count: params[:pfmp][:day_count])
        @pfmp.student.update!(address_params)
      end
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  notice: t("flash.pfmps.rectified")
    else
      redirect_to school_year_class_schooling_pfmp_path(selected_school_year, @classe, @schooling, @pfmp),
                  alert: t("flash.pfmps.cannot_rectify")
    end
  rescue ActiveRecord::RecordInvalid
    render :confirm_rectification, status: :unprocessable_entity
  end

  def destroy
    if @pfmp.destroy
      redirect_to student_path(@schooling.student),
                  notice: t("flash.pfmps.destroyed", name: @schooling.student.full_name)
    else
      redirect_to student_path(@schooling.student),
                  alert: t("flash.pfmps.not_destroyed")
    end
  end

  private

  def address_params
    params.require(:pfmp).permit(
      :address_line1,
      :address_line2,
      :address_postal_code,
      :address_city,
      :address_city_insee_code,
      :address_country_code
    )
  end

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date,
      :day_count
    )
  end
end
