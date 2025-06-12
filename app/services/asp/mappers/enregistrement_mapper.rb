# frozen_string_literal: true

module ASP
  module Mappers
    class EnregistrementMapper
      attr_reader :schooling

      def initialize(schooling)
        @schooling = schooling
      end

      def id_enregistrement
        schooling.id
      end

      def id_individu
        schooling.student.asp_individu_id
      end
    end
  end
end
