# frozen_string_literal: true

module StudentApi
  class << self
    def fetch_students!(establishment)
      api_for(establishment).fetch_and_parse!
    end

    def api_for(establishment)
      provider = establishment.principal&.provider

      case provider
      when "fim"
        Sygne.new(establishment)
      else
        raise "Provider has no matching API"
      end
    end
  end
end
