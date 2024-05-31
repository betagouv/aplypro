# frozen_string_literal: true

module StudentsApi
  class Base
    class << self
      RESOURCES = %i[
        establishment_students
        student
        student_schoolings
      ].freeze

      def identifier
        module_parent_name.demodulize
      end

      def base_url
        ENV.fetch("APLYPRO_#{identifier.upcase}_URL")
      end

      def fetch_resource(resource_type, params)
        send("fetch_#{resource_type}", params)
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

      private

      RESOURCES.each do |resource|
        define_method "fetch_#{resource}" do |params|
          url = send("#{resource}_endpoint", params)

          get(url)
        end
      end
    end
  end
end
