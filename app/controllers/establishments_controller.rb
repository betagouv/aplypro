# frozen_string_literal: true

class EstablishmentsController < ApplicationController
  include Zipline

  def create_attributive_decisions
    redirect_to classes_path, status: :forbidden and return if !current_user.can_generate_attributive_decisions?

    @etab.update!(generating_attributive_decisions: true)

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

  private

  def attributive_decisions_archive_name
    "#{@etab.uai}_décisions_d_attribution_#{Time.zone.today}.zip"
  end

  def fetch_student_address!(student)
    FetchStudentAddressJob.new(student).perform_now
  rescue Faraday::Error => e
    Sentry.capture_exception(e)
  end
end
