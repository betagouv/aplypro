# frozen_string_literal: true

module IdentityMappers
  class Base
    attr_accessor :attributes

    # List of establishment types : https://infocentre.pleiade.education.fr/bcn/workspace/viewTable/n/N_TYPE_UAI
    ACCEPTED_ESTABLISHMENT_TYPES = %w[LYC LP SEP EREA].freeze
    FREDURNERESP_MAPPING = %i[uai type category activity tna_sym tty_code tna_code].freeze
    FREDURNE_MAPPING     = %i[uai type category activity uaj tna_sym tty_code tna_code].freeze

    def initialize(attributes)
      @attributes = normalize(attributes)
    end

    def normalize(attributes)
      attributes
    end

    def parse_responsibility_line(line)
      FREDURNERESP_MAPPING.zip(line.split("$")).to_h
    end

    def parse_line(line)
      FREDURNE_MAPPING.zip(line.split("$")).to_h
    end

    def director?
      attributes["FrEduFonctAdm"] == "DIR"
    end

    def no_value?(line)
      line.blank? || line == "X"
    end

    def relevant?(attrs)
      ACCEPTED_ESTABLISHMENT_TYPES.include?(attrs[:tty_code])
    end

    def no_responsibilities?
      establishments_in_responsibility.none?
    end

    def no_access_for_email?(email)
      establishments_authorised_for(email).none?
    end

    def establishments_authorised_for(email)
      normal_uais
        .filter_map { |uai| Establishment.find_by(uai:) }
        .select     { |establishment| establishment.invites?(email) }
    end

    def establishments_in_responsibility
      responsibility_uais
        .map { |uai| Establishment.find_or_create_by!(uai: uai) }
    end

    def responsibility_uais
      return [] if !director?

      Array(attributes["FrEduRneResp"])
        .reject { |line| no_value?(line) }
        .map    { |line| parse_responsibility_line(line) }
        .filter { |attributes| relevant?(attributes) }
        .pluck(:uai)
    end

    def normal_uais
      Array(attributes["FrEduRne"])
        .reject { |line| no_value?(line) }
        .map    { |line| parse_line(line) }
        .filter { |attributes| relevant?(attributes) }
        .pluck(:uai)
    end

    def all_indicated_uais
      responsibility_uais + normal_uais
    end
  end
end
