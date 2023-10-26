# frozen_string_literal: true

module StudentApi
  class Base
    attr_reader :establishment

    def initialize(establishment)
      @establishment = establishment
    end

    def base_url
      ENV.fetch("APLYPRO_#{identifier.upcase}_URL")
    end

    def identifier
      self.class.name.demodulize
    end

    def response
      @response ||= fetch!
    end

    def parse
      mapper.new(response, establishment).parse!
    end

    def mapper
      "Student::Mappers::#{identifier}".constantize
    end

    def inspect
      "#{self.class.name}: #{establishment.uai}"
    end

    def clear!
      @response = nil
    end

    alias fetch_and_parse! parse
  end
end
