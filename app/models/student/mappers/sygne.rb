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

        # FIXME: this can definitely be simplified, and will be once
        # the use_mefstat4? hack is gone for a start.
        #
        # rubocop:disable Metrics/AbcSize
        def map_payload(payload, establishment)
          mefkey = use_mefstat4? ? "niveau" : "mef"

          payload
            .group_by { |obj| [obj["classe"], obj[mefkey]] }
            .map do |key, eleves|
            label, mef_or_mefstat4 = key

            mef = find_mef(mef_or_mefstat4)

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

        def use_mefstat4?
          ENV.fetch("APLYPRO_SYGNE_USE_MEFSTAT4").present?
        end

        def find_mef(mef_or_mefstat4)
          @all ||= Mef.all

          if use_mefstat4?
            @all.find { |m| m.mefstat4 == mef_or_mefstat4 }
          else
            @all.find_by(code: mef_or_mefstat4)
          end
        end
      end
    end
  end
end
