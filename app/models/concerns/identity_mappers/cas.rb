# frozen_string_literal: true

module IdentityMappers
  class Cas < Base
    def normalize(attributes)
      attributes["attributes"]
        .to_h
        .tap do |attrs|
        attrs["FrEduRneResp"] = attrs.delete("fr_edu_rne_resp")
        attrs["FrEduRne"] = attrs.delete("fr_edu_rne")
      end
    end
  end
end
