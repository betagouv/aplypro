# frozen_string_literal: true

module Generator
  module Pfmp
    class PfmpDocument < Document
      attr_reader :pfmp, :rib

      def initialize(schooling)
        @rib = schooling.student.rib(schooling.establishment.id)
        super
      end

      def render
        setup_styles
        header
        summary
        articles
      end

      def write
        io = StringIO.new

        schooling.pfmps.each do |pfmp|
          @pfmp = pfmp
          render
        end

        composer.write(io)
        io.rewind
        io
      end
    end
  end
end
