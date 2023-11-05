# frozen_string_literal: true

class Student
  module AddressMappers
    class Sygne < Base
      ADDRESS_MAPPING = {
        postal_code: "adrResidenceEle.codePostal",
        address_line1: "adrResidenceEle.adresseLigne1",
        address_line2: "adrResidenceEle.adresseLigne2",
        country_code: "adrResidenceEle.codePays",
        city_insee_code: "adrResidenceEle.codeCommuneInsee",
        city: "adrResidenceEle.libelleCommune"
      }.freeze
    end
  end
end
