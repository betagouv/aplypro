# frozen_string_literal: true

require "hexapdf"

module Generator
  module Pfmp
    class PfmpDocument < Document
      attr_reader :pfmp, :rib

      def initialize(pfmp)
        @pfmp = pfmp
        schooling = pfmp.schooling
        @rib = schooling.student.rib(schooling.establishment.id)
        super(schooling)
      end
    end
  end
end
