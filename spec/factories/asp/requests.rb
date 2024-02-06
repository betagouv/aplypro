# frozen_string_literal: true

FactoryBot.define do
  factory :asp_request, class: "ASP::Request" do
    sent_at { DateTime.now }
  end
end
