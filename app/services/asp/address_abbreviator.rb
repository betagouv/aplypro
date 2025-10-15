# frozen_string_literal: true

module ASP
  class AddressAbbreviator
    ABBREVIATIONS = {
      "Boulevard" => "Bvd",
      "Appartement" => "Apt",
      "Numéro" => "Num",
      "Place" => "Plc",
      "Chemin" => "Ch",
      "Impasse" => "Imp",
      "Résidence" => "Rdce"
    }.freeze

    def self.abbreviate(text, max_length:)
      return nil if text.blank?
      return text if text.length <= max_length

      abbreviated_text = text.dup

      ABBREVIATIONS.each do |full_word, abbreviation|
        abbreviated_text.gsub!(/\b#{Regexp.escape(full_word)}\b/i, abbreviation)
      end

      abbreviated_text
    end
  end
end
