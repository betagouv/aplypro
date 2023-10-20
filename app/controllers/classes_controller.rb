# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_all_classes, only: :index
  before_action :set_classe, only: %i[show bulk_pfmp create_bulk_pfmp]

  def index
    redirect_to welcome_path and return unless current_user.welcomed?

    infer_page_title
  end

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path

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
    add_breadcrumb t("pages.titles.classes.show", name: @classe.label), class_path(@classe)

    infer_page_title
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date
    )
  end

  def set_all_classes
    @classes = @etab.classes.includes(:mef, students: %i[rib pfmps], schoolings: :attributive_decision_attachment)
  end

  def set_classe
    @classe = Classe
              .includes(students: [:rib, { pfmps: :transitions }])
              .where(establishment: @etab)
              .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to classes_path, alert: t("errors.classes.not_found") and return
  end
end
