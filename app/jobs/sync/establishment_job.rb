# frozen_string_literal: true

module Sync
  class EstablishmentJob < ApplicationJob
    queue_as :default

    def perform(establishment)
      raw = EstablishmentsApis::EstablishmentApi.fetch!(establishment.uai)
      data = raw["results"]

      return true if data.blank?
      raise "there are more than one establishment returned by the API" if data.many?

      attributes = Establishment::API_MAPPING.to_h do |col, attr|
        [attr, data.first[col]]
      end

      establishment.update!(attributes)
    end
  end
end
