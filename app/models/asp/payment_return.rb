# frozen_string_literal: true

module ASP
  class PaymentReturn < ApplicationRecord
    has_one_attached :file

    has_many :asp_payment_requests,
             class_name: "ASP::PaymentRequest",
             dependent: :nullify,
             inverse_of: :asp_payment_return

    validates :filename, presence: true, uniqueness: true

    def self.create_with_file!(io:, filename:)
      create!(filename: filename)
        .file.attach(
          io: StringIO.new(io),
          filename: filename,
          content_type: "text/xml"
        )
    end

    def parse_response_file!(_type)
      ASP::Readers::PaymentsFileReader.new(io: file.download, record: self).process!
    end
  end
end
