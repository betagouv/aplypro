# frozen_string_literal: true

FactoryBot.define do
  factory :classe do
    establishment factory: %i[establishment with_fim_user]

    school_year { SchoolYear.current }
    mef { Mef.take }

    sequence(:label) { |n| "2NDE#{n}" }

    trait :with_students do
      transient do
        students_count { 5 }
      end

      after(:create) do |classe, evaluator|
        # The schooling factory makes one student per schooling
        create_list(:schooling, evaluator.students_count, classe: classe)
      end
    end

    trait :with_former_students do
      transient do
        students_count { 5 }
      end

      after(:create) do |classe, evaluator|
        # The schooling factory makes one student per schooling
        create_list(:schooling, evaluator.students_count, :closed, classe: classe)
      end
    end
  end
end
