# frozen_string_literal: true

module ASP
  class RibNameSanitiser
    DASH = "-"
    APOSTROPHE = "'"
    SPACE = " "
    NOTHING = nil

    SUBSTITUTION_MAP = {
      DASH => %w[–],
      APOSTROPHE => %w[´ ’],
      SPACE => %w[;].push("­"), # soft-hypen, not a space
      NOTHING => %w[^ >]
    }.freeze

    ALLOWED_CHARACTERS = %w[/ - ? : ( ) . , '].freeze
    RIB_NAME_MASK = /\A[\s[[:alnum:]]#{ALLOWED_CHARACTERS.map { |c| Regexp.escape(c) }.join}]+\z/

    def self.call(name)
      new.call(name)
    end

    def call(name)
      characters = name.chars

      characters
        .map { |char| substitute(char) }
        .filter { |char| allowed?(char) }
        .join
        .squish
    end

    def substitute(char)
      substitution = SUBSTITUTION_MAP.find { |_k, v| v.include?(char) }

      if substitution.present?
        substitution.first
      else
        char
      end
    end

    def allowed?(char)
      RIB_NAME_MASK.match?(char)
    end
  end
end
