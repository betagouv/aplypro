# frozen_string_literal: true

module StudentApi
  class << self
    def fetch_students!(provider, uai)
      api_for(provider, uai).fetch_and_parse!
    end

    def fetch_student_data!(provider, uai, ine)
      api_for(provider, uai).fetch_student_data!(ine)
    end

    def api_for(provider, uai)
      klass = "StudentApi::#{provider.capitalize}".constantize

      klass.new(uai)
    rescue NameError
      raise "no matching API found for #{provider}"
    end
  end
end
