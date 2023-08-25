# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_principal!
  before_action :set_etab
  before_action :set_all_classes, only: :index
  before_action :set_classe, only: %i[show bulk_pfmp create_bulk_pfmp]

  def set_all_classes
    @classes = @etab.classes.includes(:mef, students: %i[pfmps rib])
  end

  def index
    infer_page_title

    FetchStudentsJob.perform_later(@etab) if @classes.none?
  end

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path

    infer_page_title(name: @classe.label)
  end

  def create_bulk_pfmp
    respond_to do |format|
      if @classe.create_bulk_pfmp(pfmp_params)
        format.html { redirect_to class_path(@classe), notice: t("pfmps.new.success") }
      else
        format.html { render :bulk_pfmp, status: :unprocessable_entity }
      end
    end
  end

  def bulk_pfmp
    @pfmp = Pfmp.new

    infer_page_title
  end

  private

  def pfmp_params
    params.require(:pfmp).permit(
      :start_date,
      :end_date
    )
  end

  def set_etab
    @etab = current_principal.establishment
  end

  def set_classe
    @classe = Classe.includes(students: %i[pfmps rib]).find(params[:id])
  end
end
