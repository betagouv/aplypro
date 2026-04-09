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

    trait :correction_adresse do
      after(:build) do |request|
        request.correction_adresse = true
      end

      after(:create) do |request, ctx|
        request.correction_adresse_file.attach(io: StringIO.new(ctx.outfile), filename: ctx.filename)
      end
    end
  end
end
