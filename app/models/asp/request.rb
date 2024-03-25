# frozen_string_literal: true

module ASP
  class Request < ApplicationRecord
    has_one_attached :file, service: :ovh_asp
    has_one_attached :rejects_file, service: :ovh_asp
    has_one_attached :integrations_file, service: :ovh_asp

    has_many :asp_payment_requests, class_name: "ASP::PaymentRequest", dependent: :nullify, inverse_of: :asp_request

    attr_reader :asp_file

    def send!(rerun: false)
      ActiveRecord::Base.transaction do
        @asp_file = ASP::Entities::Fichier.new(asp_payment_requests)

        @asp_file.validate!

        attach_asp_file!
        drop_file!
        update_sent_timestamp!
        update_requests! unless rerun
      end
    end

    def drop_file!
      ASP::Server.drop_file!(
        io: @asp_file.to_xml,
        path: @asp_file.filename
      )
    end

    def update_sent_timestamp!
      update!(sent_at: DateTime.now)
    end

    def update_requests!
      asp_payment_requests.each(&:mark_as_sent!)
    end

    def attach_asp_file!
      file.attach(
        io: StringIO.new(@asp_file.to_xml),
        content_type: "text/xml",
        filename: @asp_file.filename
      )
    end
  end
end
