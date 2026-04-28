# frozen_string_literal: true

module ASP
  class AddressAbbreviator
    class << self
      EXTENSION_CODE_ABBREVIATIONS_MAP = {
        BIS: "B",
        TER: "T",
        QUATER: "Q",
        QUINQUIES: "C"
      }
      ROAD_TYPE_ABBREVIATIONS_PATH = Rails.root.join("data/postal-addresses-abbreviations/road-type.csv")
      COMMON_NAMES_ABBREVIATIONS_PATH = Rails.root.join("data/postal-addresses-abbreviations/common-names.csv")

      def abbreviate_road_type(text, max_length:)
        return nil if text.blank?
        return text if text.length <= max_length

        abbreviated_text = normalize(text.dup)

        # S? makes each CSV entry also match its plural form (e.g. ALLEE matches ALLEES)
        # so the CSV only needs singular entries
        load_abbreviations(ROAD_TYPE_ABBREVIATIONS_PATH).each do |full_word, abbreviation|
          abbreviated_text.gsub!(/\b#{Regexp.escape(full_word)}S?\b/i, abbreviation)
        end

        abbreviated_text
      end

      def abbreviate_address_line(text, max_length:)
        return nil if text.blank?
        return text if text.length <= max_length

        abbreviated_text = normalize(text.dup)

        load_abbreviations(COMMON_NAMES_ABBREVIATIONS_PATH).each do |full_word, abbreviation|
          abbreviated_text.gsub!(/\b#{Regexp.escape(full_word)}\b/i, abbreviation)
        end

        abbreviated_text
      end

      private

      def load_abbreviations(csv_path)
        Rails.cache.fetch("abbreviations_cache/#{csv_path}", expires_in: 3.hours) do
          CSV.read(csv_path, headers: true)
             .map { |row| [row["full"], row["abbreviated"]] }
             .sort_by { |full, _| -full.length }
             .to_h
        end
      end

      def normalize(text)
        text.unicode_normalize(:nfkd)
            .encode("UTF-8", replace: "")
            .upcase
            .gsub(/[[:punct:]]/, " ")
            .gsub(/[^A-Z0-9\s]/, "")
            .squeeze(" ")
            .strip
      end
    end
  end
end
