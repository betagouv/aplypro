# frozen_string_literal: true

module ASP
  class ApplicationController < ActionController::Base
    layout "application"

    before_action :authenticate_asp_user!

    protected

    def current_user
      current_asp_user
    end
  end
end
