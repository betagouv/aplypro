# frozen_string_literal: true

class EstablishmentsController < ApplicationController
  def index
    @etabs = Establishment.all
  end
end
