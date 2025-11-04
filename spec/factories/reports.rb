# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    school_year
    skip_schema_validation { true }
    data do
      {
        "global_data" => [
          Report::HEADERS,
          Array.new(Report::HEADERS.length, 0)
        ],
        "bops_data" => [
          ["BOP"] + Report::HEADERS,
          ["ENPU"] + Array.new(Report::HEADERS.length, 0)
        ],
        "menj_academies_data" => [
          ["Académie"] + Report::HEADERS,
          ["Paris"] + Array.new(Report::HEADERS.length, 0)
        ],
        "establishments_data" => [
          ["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public"] + Report::HEADERS,
          ["0010001A", "Lycée Test", "MENJ", "Paris", "Public"] + Array.new(Report::HEADERS.length, 0)
        ]
      }
    end
    created_at { Time.current }

    trait :with_schema_validation do
      skip_schema_validation { false }
    end
  end
end
