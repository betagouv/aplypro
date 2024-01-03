# frozen_string_literal: true

class EstablishmentsController < ApplicationController
  before_action :check_director,
                :update_and_check_confirmed_director,
                only: :create_attributive_decisions

  include Zipline

  def create_attributive_decisions
    mark_attributive_decision_generation!

    GenerateMissingAttributiveDecisionsJob.perform_later(@etab)

    redirect_to root_path
  end

  def download_attributive_decisions
    documents = @etab
                .current_schoolings
                .with_attached_attributive_decision
                .map(&:attributive_decision)
                .map { |d| [d, d.key] }

    zipline(documents, attributive_decisions_archive_name)
  end

  def select
    infer_page_title

    @user = current_user
  end

  private

  def check_director
    redirect_to home_path, status: :forbidden and return unless current_user.can_try_to_generate_attributive_decisions?
  end

  def update_and_check_confirmed_director
    update_confirmed_director!

    return if current_user.can_generate_attributive_decisions?

    redirect_to home_path, alert: t("panels.attributive_decisions.not_director") and return
  end

  def attributive_decisions_archive_name
    "#{@etab.uai}_décisions_d_attribution_#{Time.zone.today}.zip"
  end

  # FIXME: this isn't great but the job might not have actually kicked
  # in by the time the page is refreshed so trigger a synchronous DB
  # update to mark the generation process as started
  def mark_attributive_decision_generation!
    @etab
      .schoolings
      .without_attributive_decisions
      .update_all(generating_attributive_decision: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def update_confirmed_director!
    @etab.update(confirmed_director: current_user) if params[:confirmed_director] == "1"
  end
end
