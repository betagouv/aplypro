# frozen_string_literal: true

module StudentApi
  class Base
    attr_reader :establishment

    def initialize(establishment)
      @establishment = establishment
    end

    def endpoint
      ENV.fetch("APLYPRO_#{identifier}_URL") % @establishment.uai
    end

    def identifier
      raise
    end
  end
end
