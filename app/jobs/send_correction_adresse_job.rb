# frozen_string_literal: true

class SendCorrectionAdresseJob < ApplicationJob
  queue_as :payments
  sidekiq_options retry: false

  def perform(pfmp_ids)
    payment_requests = Pfmp.where(id: pfmp_ids)
                           .filter_map { |pfmp| pfmp.payment_requests.order(:created_at).last }

    return if payment_requests.empty?

    enrich_with_rnvp!(payment_requests.map(&:student))

    ASP::Request.create!(correction_adresse: true).send_correction_adresse!(payment_requests)
  end

  private

  def enrich_with_rnvp!(students)
    data = Omogen::Rnvp.new.addresses(students).index_by { |address| address[:id] }
    students.each { |s| s.rnvp_data = data[s.id] }
  end
end
