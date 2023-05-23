# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_principal!
  before_action :set_etab
  before_action :set_classe, only: :show

  def index
    @classes = @etab.classes
  end

  def show; end

  private

  def set_etab
    @etab = current_principal.establishment
  end

  def set_classe
    @classe = Classe.find(params[:id])
  end
end
