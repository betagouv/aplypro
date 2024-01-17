# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :user do
    uid { Faker::Alphanumeric.alpha }
    name { Faker::Name.name }
    provider { "MyString" }
    secret { "MyString" }
    token { "MyString" }
    email { Faker::Internet.email }
    welcomed { true }

    trait :newbie do
      welcomed { false }
    end

    transient do
      establishment { create(:establishment) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    end

    trait :with_selected_establishment do
      after(:create) do |user|
        raise "ambiguous trait: user has more than one establishment" if user.establishments.many?

        user.update!(establishment: user.establishments.first)
      end
    end

    trait :director do
      after(:create) do |user, context|
        EstablishmentUserRole
          .find_or_initialize_by(establishment: context.establishment, user: user)
          .update!(role: :dir)
      end
    end

    trait :authorised do
      after(:create) do |user, context|
        EstablishmentUserRole
          .find_or_initialize_by(establishment: context.establishment, user: user)
          .update!(role: :authorised)
      end
    end

    trait :confirmed_director do
      director

      after(:create) do |user, context|
        context.establishment.update!(confirmed_director: user)
      end
    end
  end
end
