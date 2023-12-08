# frozen_string_literal: true

class HomeController < ApplicationController
  layout "maintenance", only: :maintenance

  skip_before_action :authenticate_user!, only: %i[maintenance index login]

  before_action :show_welcome_screen, only: :home

  def index
    redirect_to home_path and return if user_signed_in?

    redirect_to login_url
  end

  def home
    infer_page_title
    @inhibit_title = true

    current_classes = @etab.classes.current

    @students_count = current_classes.joins(:active_students).count
    @attributive_decisions_count = @etab.schoolings.current.joins(:attributive_decision_attachment).count
    @ribs_count = current_classes.joins(students: :rib).count
    @pfmps_counts = pfmp_counts
  end

  def welcome
    @inhibit_nav = true

    current_user.update!(welcomed: true)
  end

  def maintenance
    redirect_to root_path and return if !maintenance_mode?

    @msg = ENV.fetch("APLYPRO_MAINTENANCE_REASON")
  end

  def login
    infer_page_title
  end

  def legal; end

  def faq; end

  private

  def pfmp_counts
    pfmps = Pfmp
            .joins(schooling: :classe)
            .merge(@etab.classes.current)

    PfmpStateMachine.states.index_with { |state| pfmps.in_state(state).count }
  end

  def show_welcome_screen
    redirect_to welcome_path and return unless current_user.welcomed?
  end
end
