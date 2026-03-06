# frozen_string_literal: true

class SendCorrectionAdresseJob < ApplicationJob
  queue_as :payments
  sidekiq_options retry: false

  def perform(pfmp_ids)
    payment_requests = Pfmp.where(id: pfmp_ids)
                           .filter_map { |pfmp| pfmp.payment_requests.order(:created_at).last }

    return if payment_requests.empty?

    ASP::Request.create!(correction_adresse: true).send_correction_adresse!(payment_requests)
  end
end
