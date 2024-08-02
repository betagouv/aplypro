# frozen_string_literal: true

module ASP
  class PaymentReturn < ApplicationRecord
    has_one_attached :file
    has_one_attached :rectifications_file

    has_many :asp_payment_requests,
             class_name: "ASP::PaymentRequest",
             dependent: :nullify,
             inverse_of: :asp_payment_return

    validates :filename, presence: true, uniqueness: true

    def parse_response_file!(_type)
      file.open do |tempfile|
        ASP::Readers::PaymentsFileReader.new(io: tempfile, record: self).process!
      end
    end
  end
end
