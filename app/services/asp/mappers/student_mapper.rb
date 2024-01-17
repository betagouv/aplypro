# frozen_string_literal: true

module ASP
  module Mappers
    class StudentMapper
      MAPPING = {
        prenom: :first_name,
        nomusage: :last_name,
        nomnaissance: :last_name,
        datenaissance: :birthdate,
        sexe: :biological_sex,
        codeinseepaysnai: :birthplace_country_insee_code,
        codeinseecommune: :birthplace_city_insee_code
      }.freeze

      # yes, we know. It's 2024 and we're still doing this silly
      # mapping but we're dealing with legacy systems that aren't
      # aware yet that this is wrong, nor do our APIs provide any
      # clues as to what the gender of our students might be.
      GENDER_FOR_SEX = {
        male: "M",
        female: "MME"
      }.freeze

      attr_reader :student

      def initialize(payment)
        @student = payment.student
      end

      MAPPING.each do |name, attr|
        define_method(name) { student[attr] }
      end

      def titre
        GENDER_FOR_SEX[student.biological_sex.to_sym]
      end
    end
  end
end
