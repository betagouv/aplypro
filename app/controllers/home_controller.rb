# frozen_string_literal: true

class HomeController < ApplicationController
  layout "maintenance", only: :maintenance

  def index
    (redirect_to home_path and return) if user_signed_in?

    redirect_to login_url
  end

  def home
    redirect_to welcome_path and return unless current_user.welcomed?

    @page_title = t("pages.titles.home.home")
    @inhibit_title = true

    current_classes = @etab.classes.current
    @students_count = current_classes.joins(:students).count
    @attributive_decisions_count = current_classes.with_attributive_decisions.count
    @ribs_count = current_classes.joins(students: :rib).count
    @pfmps_counts = pfmp_counts
  end

  def welcome
    @inhibit_nav = true

    current_user.update!(welcomed: true)
  end

  def maintenance
    @msg = ENV.fetch("APLYPRO_MAINTENANCE_REASON")
  end

  def login
    infer_page_title
  end

  def legal; end

  private

  def pfmp_counts
    pfmps = Pfmp
            .joins(schooling: :classe)
            .merge(@etab.classes.current)

    PfmpStateMachine.states.index_with { |state| pfmps.in_state(state).count }
  end
end
