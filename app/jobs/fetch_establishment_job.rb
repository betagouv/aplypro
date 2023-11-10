# frozen_string_literal: true

class FetchEstablishmentJob < ApplicationJob
  queue_as :default

  rescue_from EstablishmentError, with: :establishment_failure

  def perform(establishment)
    raw = EstablishmentApi.fetch!(establishment.uai)

    records = raw["records"]

    raise EstablishmentError if records.empty?

    data = raw["records"].first["fields"]

    attributes = Establishment::API_MAPPING.to_h do |col, attr|
      [attr, data[col]]
    end

    establishment.update!(attributes)
  end

  def establishment_failure
    Sentry.capture_exception(error)
  end
end

class EstablishmentError < StandardError; end
