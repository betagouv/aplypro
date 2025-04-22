# frozen_string_literal: true

class HomeController < ApplicationController
  layout "maintenance", only: :maintenance

  skip_before_action :authenticate_user!, only: %i[maintenance index login legal]

  before_action :show_welcome_screen, only: :home
  before_action :infer_page_title, except: %i[index maintenance]

  def index
    redirect_to school_year_home_path(SchoolYear.current) and return if user_signed_in?

    redirect_to new_user_session_path
  end

  def home
    @inhibit_title = true

    @establishment_facade = EstablishmentFacade.new(current_establishment, selected_school_year)
  end

  def welcome
    @inhibit_banner = true
    @inhibit_nav = true

    current_user.update!(welcomed: true)
  end

  def maintenance
    redirect_to root_path and return if !maintenance_mode?

    @msg = ENV.fetch("APLYPRO_MAINTENANCE_REASON")
  end

  def login; end

  def legal; end

  def faq
    @inhibit_title = true
  end

  def accessibility; end

  private

  def show_welcome_screen
    redirect_to welcome_path and return unless current_user.welcomed?
  end
end
