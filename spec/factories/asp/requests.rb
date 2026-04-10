# frozen_string_literal: true

FactoryBot.define do
  factory :asp_request, class: "ASP::Request" do
    sent_at { DateTime.now }

    transient do
      outfile { "some content" }
      filename { "filename.xml" }
    end

    trait :sent do
      with_request

      after(:create) do |request, ctx|
        request.file.attach(io: StringIO.new(ctx.outfile), filename: ctx.filename)
      end
    end

    trait :with_request do
      after(:build) do |request|
        request.asp_payment_requests << create(:asp_payment_request, :ready)
      end
    end
  end
end
