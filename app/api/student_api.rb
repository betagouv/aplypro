# frozen_string_literal: true

module StudentApi
  class << self
    def fetch_students!(establishment)
      collection = api_for(establishment).fetch_and_parse!

      collection.each(&:save!)
    end

    def api_for(establishment)
      provider = establishment.user&.provider

      case provider
      when "fim", "developer"
        Sygne.new(establishment)
      when "masa"
        Fregata.new(establishment)
      else
        raise "Provider has no matching API"
      end
    end
  end
end
