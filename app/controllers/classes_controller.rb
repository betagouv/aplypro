# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_all_classes, only: :index
  before_action :set_classe, except: :index

  def index
    redirect_to welcome_path and return unless current_user.welcomed?

    infer_page_title
  end

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    @nb_students = @classe.active_students.count
    @nb_pending_pfmp = @classe.pfmps.in_state(:pending).count
    @nb_pfmps = @classe.active_pfmps.count
    @nb_ribs = @classe.active_students.joins(:rib).count

    infer_page_title(name: @classe)
  end

  def create_bulk_pfmp
    @pfmp = Pfmp.new(pfmp_params)

    if @classe.create_bulk_pfmp(pfmp_params)
      redirect_to class_path(@classe), notice: t("pfmps.new.success")
    else
      @pfmp.save # save to populate the errors hash
      @pfmp.errors.delete(:schooling) # remove the one about schooling

      render :bulk_pfmp, status: :unprocessable_entity
    end
  end

  def bulk_pfmp
    @pfmp = Pfmp.new

    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe), class_path(@classe)

    infer_page_title
  end

  def bulk_pfmp_completion
    add_breadcrumb t("pages.titles.classes.index"), classes_path
    add_breadcrumb t("pages.titles.classes.show", name: @classe), class_path(@classe)

    infer_page_title

    @pfmps = @classe
             .pfmps
             .in_state(:pending)
             .joins(:student)
             .order(:last_name, :first_name, :start_date)
  end

  def update_bulk_pfmp
    @pfmps = bulk_pfmp_completion_params[:pfmps].map do |pfmp_params|
      Pfmp.find(pfmp_params[:id]).tap do |pfmp|
        pfmp.day_count = pfmp_params[:day_count]
      end
    end

    if @pfmps.all?(&:save)
      redirect_to class_path(@classe), notice: t("pfmps.update.success")
    else
      render :bulk_pfmp_completion, status: :unprocessable_entity
    end
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date
    )
  end

  def bulk_pfmp_completion_params
    params.require(:classe).permit(
      pfmps: %i[id day_count]
    )
  end

  def set_all_classes
    @classes = @etab
               .classes
               .current
               .includes(:mef, :active_pfmps, active_students: :rib)
  end

  def set_classe
    @classe = Classe
              .where(establishment: @etab)
              .includes(active_schoolings: [student: :rib])
              .find(params[:id])

    @schoolings = @classe.active_schoolings
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end
end
