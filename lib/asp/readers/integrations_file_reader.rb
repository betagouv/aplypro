# frozen_string_literal: true

require "csv"

module ASP
  module Readers
    class IntegrationsFileReader
      attr_reader :filepath

      def initialize(filepath)
        @filepath = filepath
      end

      def process!
        CSV.foreach(filepath, headers: true, col_sep: ";", encoding: "ISO8859-1") do |row|
          id = row["Numero enregistrement"]

          student = Student.find(id)

          # student.payments.in_state(:processing).each(&:fail!)
        end
      end
    end
  end
end
