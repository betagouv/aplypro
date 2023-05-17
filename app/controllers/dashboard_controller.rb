class DashboardController < ApplicationController
  before_action :authenticate_principal!

  def index
  end
end
