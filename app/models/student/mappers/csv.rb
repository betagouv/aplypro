# frozen_string_literal: true

class Student
  module Mappers
    class CSV < Base
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

      class ClasseMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        define! do
          deep_symbolize_keys

          rename_keys(label_classe: :label)

          accept_keys %i[label mef_code]
        end
      end

      def map_schooling!(classe, student, entry)
        schooling = Schooling.find_or_initialize_by(classe: classe, student: student) do |sc|
          sc.start_date = entry["date_début"]
          sc.end_date = entry["date_fin"]
          sc.status = :student
        end

        student.close_current_schooling! if schooling.open? && schooling != student.current_schooling

        schooling.save!
      end
    end
  end
end
