class EstablishmentsController < ApplicationController
  def index
    @etabs = Establishment.all
  end
end
