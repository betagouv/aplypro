# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return if principal_signed_in?

    redirect_to login_url
  end

  def login; end
end
