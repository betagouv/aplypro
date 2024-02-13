# frozen_string_literal: true

class Payment < ApplicationRecord
  has_many :payment_requests, class_name: "ASP::PaymentRequest", dependent: :destroy

  belongs_to :pfmp

  has_one :student, through: :pfmp
  has_one :schooling, through: :pfmp

  validates :amount, numericality: { greater_than: 0 }

  scope :paid, -> { joins(:payment_requests).merge(ASP::PaymentRequest.in_state(:paid)) }

  after_create do
    payment_requests.create!
  end
end
