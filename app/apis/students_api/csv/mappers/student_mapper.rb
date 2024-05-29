# frozen_string_literal: true

module StudentsApi
  module CSV
    module Mappers
      class StudentMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          symbolize_keys

          rename_keys(
            :prénom => :last_name,
            :nom => :first_name,
            :date_naissance => :birthdate,
            :"Sexe biologique" => :biological_sex,
            :"Code INSEE de ville de naissance" => :birthplace_city_insee_code,
            :"Code INSEE de pays de naissance" => :birthplace_country_insee_code,
            :"Code postal de résidence" => :address_postal_code,
            :"Code INSEE de ville de résidence" => :address_city_insee_code,
            :"Code INSEE de pays de résidence" => :address_country_code
          )

          map_value :biological_sex, lambda { |x|
            case x
            when "f"
              :female
            when "h"
              :male
            else
              raise ArgumentError, "could not understand a value of '#{x}' for biological_sex"
            end
          }

          accept_keys(Student.attribute_names.map(&:to_sym))
        end
      end
    end
  end
end
