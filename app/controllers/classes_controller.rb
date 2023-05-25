# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_principal!
  before_action :set_etab
  before_action :set_classe, only: :show

  def index
    infer_page_title

    @classes = @etab.classes
    @inhibit_title = true

    FetchStudentsJob.perform_later(@etab) if @classes.none?
  end

  def show
    add_breadcrumb t("pages.titles.classes.index"), classes_path

    infer_page_title(name: @classe.label)
  end

  private

  def set_etab
    @etab = current_principal.establishment
  end

  def set_classe
    @classe = Classe.find(params[:id])
  end
end
