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
      raise
    end
  end
end
