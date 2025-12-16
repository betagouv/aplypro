# frozen_string_literal: true

module ASP
  module Mappers
    class PersPhysiqueMapper
      MAPPING = {
        prenom: :first_names,
        nomusage: :last_name,
        nomnaissance: :last_name,
        datenaissance: :birthdate,
        sexe: :biological_sex
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

      def initialize(payment_request)
        @student = payment_request.student
      end

      MAPPING.each do |name, attr|
        define_method(name) { student.send(attr) }
      end

      def titre
        GENDER_FOR_SEX[student.biological_sex.to_sym]
      end

      def codeinseepaysnai
        InseeCountryCodeMapper.call(student.birthplace_country_insee_code)
      end

      def codeinseecommune
        student.birthplace_city_insee_code_exceptions
      end
    end
  end
end
