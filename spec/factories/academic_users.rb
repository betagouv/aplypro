FactoryBot.define do
  factory :academic_user, class: "Academic::User" do
    sequence(:email) { |n| "academic_user_#{n}@example.com" }
    sequence(:uid) { |n| "academic_#{n}" }
    name { Faker::Name.name }
    provider { "MyString" }
    secret { "MyString" }
    token { "MyString" }
  end
end
