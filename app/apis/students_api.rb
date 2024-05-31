# frozen_string_literal: true

module StudentsApi
  class << self
    def api_for(provider)
      "StudentsApi::#{provider.capitalize}::Api".constantize
    rescue NameError
      raise "no matching API found for #{provider}"
    end
  end
end
