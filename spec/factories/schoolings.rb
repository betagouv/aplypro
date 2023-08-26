FactoryBot.define do
  factory :schooling do
    student
    classe
    start_date { "2023-08-26" }
    end_date { "2023-08-26" }
  end
end
