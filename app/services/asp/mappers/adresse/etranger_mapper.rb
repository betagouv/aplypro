# frozen_string_literal: true

module ASP
  module Mappers
    module Adresse
      class EtrangerMapper
        attr_reader :establishment

        def initialize(payment_request)
          @establishment = payment_request.pfmp.establishment
        end

        def codecominsee
          InseeExceptionCodes.transform_insee_code(establishment.commune_code)
        end

        def codepostalcedex
          establishment.postal_code
        end

        def codetypeadr
          FranceMapper::PRINCIPAL_ADDRESS_TYPE
        end

        def codeinseepays
          InseeCodes::FRANCE_INSEE_COUNTRY_CODE
        end
      end
    end
  end
end
