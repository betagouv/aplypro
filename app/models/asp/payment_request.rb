# frozen_string_literal: true

module ASP
  class PaymentRequest < ApplicationRecord
    belongs_to :asp_request, class_name: "ASP::Request"
    belongs_to :payment
  end
end
