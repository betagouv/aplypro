# frozen_string_literal: true

class Student
  module Mappers
    module Fregata
      class << self
        FREGATA_MAPPING = {
          ine: "apprenant.ine",
          first_name: "apprenant.prenomUsuel",
          last_name: "apprenant.nomUsuel",
          birthdate: "apprenant.dateNaissance"
        }.freeze

        def map_attributes(attrs)
          FREGATA_MAPPING.transform_values do |path|
            attrs.dig(*path.split("."))
          end
        end

        # rubocop:disable Metrics/AbcSize
        def map_payload(payload, etab)
          data = payload.group_by { |item| item["division"] }

          data.map do |klass, students|
            code = students.first["sectionReference"]["codeMef"].slice(..-2)
            mef = Mef.find_by(code:)

            next if mef.nil?

            Classe.find_or_create_by!(establishment: etab, mef:, label: klass["code"]).tap do |k|
              students
                .map { |e| make_student(e) }
                .compact
                .each { |student| Schooling.find_or_create_by!(classe: k, student:) }
            end
          end.compact
        end
        # rubocop:enable Metrics/AbcSize

        def make_student(data)
          attributes = map_attributes(data)

          Student.find_or_initialize_by(ine: attributes[:ine]).tap do |student|
            student.assign_attributes(attributes)
          end
        end
      end
    end
  end
end
