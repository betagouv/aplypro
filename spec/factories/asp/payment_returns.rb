# frozen_string_literal: true

FactoryBot.define do
  factory :asp_payment_return, class: "ASP::PaymentReturn" do
    # NOTE: this needs to be a sequence because the ASP filename is
    # always something like "renvoi_paiment_{IDENTIFIER}_{DATE}" which
    # is fine if you get a file per day but not in the test suite
    # where we might create more and violate the unique filename
    # constraint on the ASP::PaymentReturn.
    sequence(:filename) do |n|
      name = build(:asp_filename, :payments)

      "#{n}-#{name}"
    end
  end
end
