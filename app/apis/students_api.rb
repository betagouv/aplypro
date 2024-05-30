# frozen_string_literal: true

module StudentsApi
  class << self
    def fetch_students!(provider, uai)
      api_for(provider, uai).fetch_and_parse!
    end

    def fetch_student_data!(provider, uai, ine)
      api_for(provider, uai).fetch_student_data!(ine)
    end

    def fetch_schooling_data!(provider, uai, ine)
      api_for(provider, uai).fetch_schooling_data!(ine)
    end

    def api_for(provider, uai)
      klass = "StudentsApi::#{provider.capitalize}::Api".constantize

      klass.new(uai)
    rescue NameError
      raise "no matching API found for #{provider}"
    end
  end
end
