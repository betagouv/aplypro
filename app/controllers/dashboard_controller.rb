# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_principal!

  def index
    @etab = current_principal.establishment
    @classes = @etab.classes

    if @classes.none?
      FetchStudentsJob.perform_later(@etab)
    end
  end
end
