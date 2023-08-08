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
            mef = Mef.find_by!(code:)

            Classe.new(establishment: etab, mef:, label: klass["code"]).tap do |k|
              eleves = students.map do |e|
                attributes = map_attributes(e)

                next if attributes[:ine].nil?

                Student.find_or_initialize_by(ine: attributes[:ine]).tap { |s| s.update(attributes) }
              end.compact

              k.students << eleves
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
