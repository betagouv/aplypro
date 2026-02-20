# frozen_string_literal: true

class SendCorrectionAdresseJob < ApplicationJob
  queue_as :payments
  sidekiq_options retry: false

  def perform(pfmp_ids)
    payment_requests = Pfmp.where(id: pfmp_ids)
                           .filter_map { |pfmp| pfmp.payment_requests.order(:created_at).last }

    return if payment_requests.empty?

    fichier = ASP::Entities::CorrectionAdresseFichier.new(payment_requests)
    fichier.validate!

    ASP::Server.upload_file!(
      io: fichier.to_xml,
      path: fichier.filename
    )
  end
end
