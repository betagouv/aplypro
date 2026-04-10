# frozen_string_literal: true

FactoryBot.define do
  factory :asp_adresse_correction_request, class: "ASP::AdresseCorrectionRequest" do
    transient do
      outfile { "some content" }
      filename { "filename.xml" }
    end

    trait :with_correction_adresse_file do
      after(:create) do |request, ctx|
        request.correction_adresse_file.attach(io: StringIO.new(ctx.outfile), filename: ctx.filename)
      end
    end
  end
end
