# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    unless principal_signed_in?
      redirect_to login_url
    end
  end

  def login
  end
end
