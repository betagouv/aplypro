# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    school_year
    skip_schema_validation { true }
    data do
      {
        "global_data" => [
          Report::GENERIC_DATA_KEYS,
          Array.new(Report::GENERIC_DATA_KEYS.length, nil)
        ],
        "bops_data" => [
          ["BOP"] + Report::GENERIC_DATA_KEYS,
          ["ENPU"] + Array.new(Report::GENERIC_DATA_KEYS.length, nil)
        ],
        "menj_academies_data" => [
          ["Académie"] + Report::GENERIC_DATA_KEYS,
          ["Paris"] + Array.new(Report::GENERIC_DATA_KEYS.length, nil)
        ],
        "establishments_data" => [
          ["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public"] + Report::GENERIC_DATA_KEYS,
          ["0010001A", "Lycée Test", "MENJ", "Paris", "Public"] + Array.new(Report::GENERIC_DATA_KEYS.length, nil)
        ]
      }
    end
    created_at { Time.current }

    trait :with_schema_validation do
      skip_schema_validation { false }
    end
  end
end
