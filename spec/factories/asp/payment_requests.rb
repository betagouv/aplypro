FactoryBot.define do
  factory :asp_payment_request, class: "ASP::PaymentRequest" do
    asp_request
    payment
  end
end
