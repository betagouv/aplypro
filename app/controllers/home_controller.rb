# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    (redirect_to classes_path and return) if principal_signed_in?

    redirect_to login_url
  end

  def login
    infer_page_title
  end
end
