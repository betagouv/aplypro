# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_return, class: "ASP::PaymentReturn" do
    filename { build(:asp_filename, :payments, identifier: Faker::Internet.uuid) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
  end
end
