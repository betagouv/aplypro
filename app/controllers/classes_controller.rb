# frozen_string_literal: true

class ClassesController < ApplicationController
  before_action :authenticate_principal!
  before_action :find_etab

  def index
    @classes = @etab.classes
  end

  def show
    @classe = Classe.find(params[:id])
  end

  private

  def find_etab
    @etab = current_principal.establishment
  end
end
