# frozen_string_literal: true

FactoryBot.define do
  factory :asp_request, class: "ASP::Request" do
    sent_at { DateTime.now }

    transient do
      outfile { "some content" }
      filename { "filename.xml" }
    end

    trait :sent do
      after(:create) do |request, ctx|
        request.file.attach(io: StringIO.new(ctx.outfile), filename: ctx.filename)
      end
    end
  end
end
