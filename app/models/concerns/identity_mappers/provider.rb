# frozen_string_literal: true

module IdentityMappers
  class Provider # rubocop:disable Metrics/ClassLength
    attr_accessor :attributes, :provider

    FREDURNERESP_MAPPING = %i[uai type category activity tna_sym tty_code tna_code].freeze
    FREDURNE_MAPPING     = %i[uai type category function uaj tna_sym tty_code tna_code].freeze
    FREDURESDEL_MAPPING  = %i[name url begin_date end_date user_name responsibilities server_id module].freeze
    FREDURESDEL_MARKER = "applicationname=aplypro"
    FREDURESDEL_RESPONSIBILITIES_PREFIX = "FrEduRneResp="

    def initialize(data)
      @provider = data["provider"].to_sym
      @attributes = data["extra"]["raw_info"]
    end

    def parse_delegation_line(line)
      FREDURESDEL_MAPPING.zip(line.split("|")).to_h
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
      (Establishment.accepted_type?(attrs[:tty_code]) &&
        !Exclusion.establishment_excluded?(attrs[:uai], nil)
      ) || Establishment::AUTHORISED_CLG_UAIS.include?(attrs[:uai])
    end

    def no_responsibilities?
      establishments_in_responsibility.none?
    end

    def no_access_for_email?(email)
      establishments_authorised_for(email).none?
    end

    def establishments_authorised_for(email)
      establishments_invited_for(email) | establishments_delegated
    end

    def establishments_invited_for(email)
      Establishment.joins(:invitations).where("invitations.email": email, "invitations.type": "EstablishmentInvitation")
    end

    def establishments_delegated
      delegated_uais.filter_map { |uai| find_or_create_establishment!(uai) }
    end

    def establishments_in_responsibility
      all_responsibility_uais
        .map { |uai| find_or_create_establishment!(uai) }
    end

    def establishments_in_responsibility_and_delegated
      establishments_in_responsibility + establishments_delegated
    end

    def find_or_create_establishment!(uai)
      Establishment
        .find_or_create_by(uai: uai)
        .tap do |establishment|
          establishment.update!({ students_provider: students_provider }) if establishment.students_provider.blank?
        end
    end

    def all_responsibility_uais
      aplypro_responsibilities + responsibility_uais
    end

    def responsibility_uais
      return [] unless director?

      Array(attributes["FrEduRneResp"])
        .reject { |line| no_value?(line) }
        .map    { |line| parse_responsibility_line(line) }
        .filter { |attributes| relevant?(attributes) }
        .pluck(:uai)
    end

    def aplypro_responsibilities
      Array(attributes["AplyproResp"]).compact
    end

    def aplypro_academies
      Array(attributes["AplyproAcademieResp"]).compact
    end

    def normal_uais
      Array(attributes["FrEduRne"])
        .reject { |line| no_value?(line) }
        .map    { |line| parse_line(line) }
        .filter { |attributes| relevant?(attributes) }
        .pluck(:uai)
    end

    def delegated_uais
      delegated_responsibilities
        .map      { |line| line.delete_prefix(FREDURESDEL_RESPONSIBILITIES_PREFIX) }
        .flat_map { |line| line.split(";") }
        .map      { |line| parse_responsibility_line(line) }
        .filter   { |attributes| relevant?(attributes) }
        .pluck(:uai)
        .uniq
    end

    def delegated_responsibilities
      Array(attributes["FrEduResDel"])
        .reject { |line| no_value?(line) }
        .map    { |line| parse_delegation_line(line) }
        .select { |delegation| aplypro_delegation?(delegation[:url]) }
        .pluck(:responsibilities)
    end

    def aplypro_delegation?(url)
      url.include?(FREDURESDEL_MARKER)
    end

    def all_indicated_uais
      all_responsibility_uais | normal_uais | delegated_uais
    end

    private

    def students_provider
      case provider
      when :fim, :academic
        "sygne"
      when :masa
        "fregata"
      else
        raise "No mapper suitable for auth provider: #{provider}"
      end
    end
  end
end
