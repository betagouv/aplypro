# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_principal!
  before_action :find_etab
  before_action :find_classe, only: :show


  def index
    @classes = @etab.classes
  end

  def show; end

  private

  def find_etab
    @etab = current_principal.establishment
  end

  def find_classe
    @classe = Classe.find(params[:id])
  end
end
