# frozen_string_literal: true

module ASP
  class PaymentReturn < ApplicationRecord
    has_one_attached :file
    has_one_attached :rectifications_file

    alias payments_file file

    has_many :asp_payment_requests,
             class_name: "ASP::PaymentRequest",
             dependent: :nullify,
             inverse_of: :asp_payment_return

    validates :filename, presence: true, uniqueness: true

    # TODO: make this a concern between request and return?
    # benefit: better syntax and extend streaming to all processing
    def parse_response_file!(type)
      public_send("#{type}_file").open do |tempfile|
        "ASP::Readers::#{type.capitalize}FileReader"
          .constantize.new(
            io: tempfile, record: self
          ).process!
      end
    end
  end
end
