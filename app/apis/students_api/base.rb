# frozen_string_literal: true

module StudentsApi
  class Base
    attr_reader :uai

    def initialize(uai)
      @uai = uai
    end

    def base_url
      ENV.fetch("APLYPRO_#{identifier.upcase}_URL")
    end

    def identifier
      self.class.module_parent_name.demodulize
    end

    def response
      @response ||= fetch!
    end

    def fetch_and_parse!
      mapper.new(response, uai).parse!
    end

    def info_mapper
      "Student::InfoMappers::#{identifier}".constantize
    end

    def mapper
      "Student::Mappers::#{identifier}".constantize
    end

    def inspect
      "#{self.class.name}: #{uai}"
    end

    def clear!
      @response = nil
    end
  end
end
