# frozen_string_literal: true

module IdentityMappers
  class Fim < Base
    def normalize(attributes)
      attributes
    end

    def responsibilities
      aplypro_responsibilities + super
    end

    def aplypro_responsibilities
      Array(attributes["AplyproResp"]).compact.map { |u| { uai: u } }
    end
  end
end
