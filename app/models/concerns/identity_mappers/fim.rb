# frozen_string_literal: true

module IdentityMappers
  class Fim < Base
    def normalize(attributes)
      attributes
    end

    def responsibility_uais
      aplypro_responsibilities + super
    end

    def aplypro_responsibilities
      Array(attributes["AplyproResp"]).compact
    end
  end
end
