# frozen_string_literal: true

module ASP
  class AddressAbbreviator
    class << self
      ROAD_TYPE_ABBREVIATIONS_PATH = Rails.root.join("data/postal-addresses-abbreviations/road-type.csv")
      COMMON_NAMES_ABBREVIATIONS_PATH = Rails.root.join("data/postal-addresses-abbreviations/common-names.csv")

      def abbreviate_road_type(text, max_length:)
        abbreviate(text, max_length: max_length, csv_path: ROAD_TYPE_ABBREVIATIONS_PATH)
      end

      def abbreviate_address_line(text, max_length:)
        abbreviate(text, max_length: max_length, csv_path: COMMON_NAMES_ABBREVIATIONS_PATH)
      end

      private

      def abbreviate(text, max_length:, csv_path:)
        return nil if text.blank?
        return text if text.length <= max_length

        abbreviated_text = normalize(text.dup)

        load_abbreviations(csv_path).each do |full_word, abbreviation|
          abbreviated_text.gsub!(/\b#{Regexp.escape(full_word)}\b/i, abbreviation)
        end

        abbreviated_text
      end

      def load_abbreviations(csv_path)
        Rails.cache.fetch("abbreviations_cache", expires_in: 3.hours) do
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
