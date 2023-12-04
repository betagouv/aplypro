# frozen_string_literal: true

FactoryBot.define do
  factory :classe do
    establishment factory: %i[establishment with_fim_user]

    mef
    sequence(:label) { |n| "2NDE#{n}" }
    start_year { 2023 }

    trait :with_students do
      transient do
        students_count { 5 }
      end

      after(:create) do |classe, evaluator|
        # The schooling factory makes one student per schooling
        create_list(:schooling, evaluator.students_count, classe: classe)
        classe.reload
      end
    end
  end
end
