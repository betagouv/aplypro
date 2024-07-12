# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_classe, except: :index

  before_action :add_bulk_action_breadcrumbs, only: %i[
    create_bulk_pfmp
    bulk_pfmp
    bulk_pfmp_completion
    update_bulk_pfmp
  ]

  def index
    infer_page_title

    @classes = current_establishment.classes.where(school_year: selected_school_year)
    @classes_facade = ClassesFacade.new(@classes)
  end

  def show
    add_breadcrumb t("pages.titles.classes.index"), school_year_classes_path(selected_school_year)
    infer_page_title(name: @classe)

    @classe_facade = ClasseFacade.new(@classe)
  end

  def create_bulk_pfmp
    if @classe.create_bulk_pfmp(pfmp_params)
      redirect_to school_year_class_path(selected_school_year, @classe), notice: t("pfmps.new.success")
    else
      @pfmp = Pfmp.new(pfmp_params)
      # TODO: clean up this hack, here we set a schooling to run conditional validations
      @pfmp.schooling = @classe.schoolings.last
      @pfmp.save # save to populate the errors hash
      @pfmp.errors.delete(:schooling) # remove the one about schooling
      render :bulk_pfmp, status: :unprocessable_entity
    end
  end

  def bulk_pfmp
    @pfmp = Pfmp.new
  end

  def bulk_pfmp_completion
    @pfmps = @classe
             .pfmps
             .includes(schooling: :student)
             .in_state(:pending)
             .joins(:student)
             .order(:last_name, :first_name, :start_date)
  end

  def update_bulk_pfmp
    @pfmps = bulk_pfmp_completion_params[:pfmps].map do |pfmp_params|
      @classe.pfmps.find(pfmp_params[:id]).tap do |pfmp|
        pfmp.day_count = pfmp_params[:day_count]
      end
    end

    if @pfmps.all?(&:save)
      redirect_to school_year_class_path(selected_school_year, @classe), notice: t("pfmps.update.success")
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

  def set_classe
    @classe = current_establishment.classes.find_by!(id: params[:id], school_year: selected_school_year)
  rescue ActiveRecord::RecordNotFound
    redirect_to school_year_classes_path(selected_school_year),
                alert: t("errors.classes.not_found") and return
  end

  def add_bulk_action_breadcrumbs
    add_breadcrumb(
      t("pages.titles.classes.index"),
      school_year_classes_path(selected_school_year)
    )
    add_breadcrumb(
      t("pages.titles.classes.show", name: @classe),
      school_year_class_path(selected_school_year, @classe)
    )
    infer_page_title
  end
end
