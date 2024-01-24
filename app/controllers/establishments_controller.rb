# frozen_string_literal: true

class EstablishmentsController < ApplicationController
  include RoleCheck

  before_action :check_director,
                :update_confirmed_director!,
                :check_confirmed_director_for_attributive_decision,
                only: :create_attributive_decisions

  include Zipline

  def create_attributive_decisions
    mark_attributive_decision_generation!

    GenerateMissingAttributiveDecisionsJob.perform_later(current_establishment)

    redirect_to root_path
  end

  def download_attributive_decisions
    documents = current_establishment
                .schoolings
                .with_attached_attributive_decision
                .map(&:attributive_decision)
                .filter(&:attached?)
                .map { |d| [d, d.key] }

    zipline(documents, attributive_decisions_archive_name)
  end

  private

  def check_confirmed_director_for_attributive_decision
    check_confirmed_director(alert_message: t("panels.attributive_decisions.not_director"))
  end

  def attributive_decisions_archive_name
    "#{current_establishment.uai}_décisions_d_attribution_#{Time.zone.today}.zip"
  end

  # FIXME: this isn't great but the job might not have actually kicked
  # in by the time the page is refreshed so trigger a synchronous DB
  # update to mark the generation process as started
  def mark_attributive_decision_generation!
    current_establishment
      .schoolings
      .without_attributive_decisions
      .update_all(generating_attributive_decision: true) # rubocop:disable Rails/SkipsModelValidations
  end
end
