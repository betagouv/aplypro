# frozen_string_literal: true

module IdentityMappers
  class Fim
    class EmptyResponsibilitiesError < StandardError
      attr_reader :attributes

      def initialize(msg = "No responsibilites indicated", attributes = {})
        @attributes = attributes
        super(msg)
      end
    end

    attr_accessor :attributes

    ACCEPTED_ESTABLISHMENT_TYPES = %w[LYC LP].freeze
    FREDURNERESP_MAPPING = %i[uai type category activity tna_sym tty_code tna_code].freeze

    def initialize(attributes)
      @attributes = attributes
    end

    def map_responsibility(line)
      FREDURNERESP_MAPPING.zip(line.split("$")).to_h
    end

    def responsibilities
      raise EmptyResponsibilitiesError.new(nil, attributes) if no_responsibilites?

      attributes["FrEduRneResp"]
        .map { |raw| map_responsibility(raw) }
        .filter { |line| relevant?(line) }
    end

    def no_responsibilites?
      attributes["FrEduRneResp"].blank? || attributes["FrEduRneResp"].all? { |value| value == no_value }
    end

    def no_value
      "X" # their choice not mine
    end

    def multiple_establishments?
      responsibilities.count > 1
    end

    def relevant?(attrs)
      ACCEPTED_ESTABLISHMENT_TYPES.include?(attrs[:tty_code])
    end

    def establishments
      responsibilities
        .pluck(:uai)
        .map { |uai| Establishment.find_or_create_by!(uai: uai) }
    end

    def create_all_establishments!
      establishments.each(&:fetch_data!)
    end
  end
end
