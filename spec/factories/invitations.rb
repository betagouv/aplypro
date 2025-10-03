# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :invitation do
    user
    sequence :email do |n|
      "user_#{n}@education.gouv.fr"
    end

    factory :establishment_invitation, class: "EstablishmentInvitation" do
      establishment
      type { "EstablishmentInvitation" }
    end

    factory :academic_invitation, class: "AcademicInvitation" do
      academy_codes { %w[01 06] }
      type { "AcademicInvitation" }
    end
  end
end
