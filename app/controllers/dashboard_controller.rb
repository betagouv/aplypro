# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_principal!

  def index
    @etab = current_principal.establishment
    @classes = @etab.classes

    FetchStudentsJob.perform_later(@etab) if @classes.none?
  end
end
