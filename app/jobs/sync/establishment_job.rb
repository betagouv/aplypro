# frozen_string_literal: true

module Sync
  class EstablishmentJob < ApplicationJob
    queue_as :default

    def perform(establishment)
      data = DataEducationApi::EstablishmentApi.result(establishment.uai)

      return true if data.nil?

      attributes = Establishment::API_MAPPING.to_h do |col, attr|
        [attr, data[col]]
      end
      attributes.delete(:email) unless establishment.email.nil?

      establishment.update!(attributes)
    end
  end
end
