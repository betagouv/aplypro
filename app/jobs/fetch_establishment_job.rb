# frozen_string_literal: true

class FetchEstablishmentJob < ApplicationJob
  queue_as :default

  def perform(establishment)
    raw = EstablishmentApi.fetch!(establishment.uai)

    return if raw["records"].blank?

    data = raw["records"].first["fields"]

    attributes = Establishment::API_MAPPING.to_h do |col, attr|
      [attr, data[col]]
    end

    establishment.update!(attributes)
  end
end
