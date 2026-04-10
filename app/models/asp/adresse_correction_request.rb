# frozen_string_literal: true

module ASP
  class AdresseCorrectionRequest < ApplicationRecord
    include ASP::ResponseFileHandling

    has_one_attached :correction_adresse_file, service: :ovh_asp
    has_one_attached :correction_adresse_integrations_file, service: :ovh_asp
    has_one_attached :correction_adresse_rejects_file, service: :ovh_asp

    def send_correction_adresse!(payment_requests)
      ActiveRecord::Base.transaction do
        asp_file = ASP::Entities::CorrectionAdresseFichier.new(payment_requests)
        asp_file.validate!
        correction_adresse_file.attach(io: StringIO.new(asp_file.to_xml),
                                       content_type: "text/xml", filename: asp_file.filename)
        ASP::Server.upload_file!(io: asp_file.to_xml, path: asp_file.filename)
        update!(sent_at: DateTime.now)
      end
    end
  end
end
