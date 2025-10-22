# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    school_year
    data do
      {
        "global_data" => [["Global Header"], ["Global Data"]],
        "bops_data" => [["BOP Header"], ["BOP Data"]],
        "menj_academies_data" => [["Academy Header"], ["Academy Data"]],
        "establishments_data" => [["Establishment Header"], ["Establishment Data"]]
      }
    end
    created_at { Time.current }
  end
end
