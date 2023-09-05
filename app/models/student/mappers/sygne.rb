# frozen_string_literal: true

class Student
  module Mappers
    module Sygne
      class << self
        SYGNE_MAPPING = {
          "prenom" => :first_name,
          "nom" => :last_name,
          "ine" => :ine,
          "dateNaissance" => :birthdate
        }.freeze

        def map_attributes(attrs)
          SYGNE_MAPPING.to_h do |attr, col|
            [col, attrs[attr]]
          end
        end

        # FIXME: this can definitely be simplified
        # rubocop:disable Metrics/AbcSize
        def map_payload(payload, establishment)
          payload
            .group_by { |obj| [obj["classe"], obj["codeMef"]] }
            .map do |key, eleves|
            label, code = key

            mef = Mef.find_by(code: code.slice(..-2))

            next if mef.nil?

            Classe.find_or_create_by!(establishment: establishment, mef:, label:).tap do |k|
              eleves
                .map { |e| make_student(e) }
                .compact
                .each do |student|
                Schooling.find_or_create_by(classe: k, student:)
              end
            end
          end.compact
        end
        # rubocop:enable Metrics/AbcSize

        def make_student(data)
          attributes = map_attributes(data)

          Student.find_or_initialize_by(ine: attributes["ine"]).tap do |student|
            student.assign_attributes(attributes)
          end
        end
      end
    end
  end
end
