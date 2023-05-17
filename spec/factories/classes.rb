FactoryBot.define do
  factory :classe do
    establishment
    mefstat
    sequence(:label) { |n| "3EME#{n}" }
  end
end
