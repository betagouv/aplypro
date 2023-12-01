# frozen_string_literal: true

module IdentityMappers
  class Cas < Base
    def students_provider
      "fregata"
    end

    def normalize(attributes)
      attributes["attributes"]
        .to_h
        .tap do |attrs|
        attrs["FrEduRneResp"] = attrs.delete("fr_edu_rne_resp")
        attrs["FrEduRne"] = attrs.delete("fr_edu_rne")
        attrs["FrEduFonctAdm"] = attrs.delete("fr_edu_fonct_adm")
      end
    end
  end
end
