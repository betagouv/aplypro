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

    # FIXME: this isn't a real mapper (as opposed to the atomic ones
    # in student_apis/*/mappers/), it's a massive bit of code that
    # update student listings, creating classes + schoolings +
    # students as required. It was originally called mapper but it
    # should be moved into its own service.
    def mapper
      "Student::Mappers::#{identifier}".constantize
    end

    # NOTE: these are "actual" mappers, they turn specific API data
    # projections into known hash structures.
    %w[schooling address classe student].each do |klass|
      define_method "#{klass}_mapper" do
        mapper = "StudentsApi::#{identifier}::Mappers::#{klass.classify}Mapper".constantize

        mapper.new
      end
    end

    def inspect
      "#{self.class.name}: #{uai}"
    end

    def clear!
      @response = nil
    end
  end
end
