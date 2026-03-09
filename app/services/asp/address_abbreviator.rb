# frozen_string_literal: true

module ASP
  class AddressAbbreviator
    ABBREVIATIONS_FILE = Rails.root.join("data/postal-address-abbreviations.csv")

    class << self
      def abbreviate(text, max_length:)
        return nil if text.blank?
        return text if text.length <= max_length

        abbreviated_text = normalize(text.dup)

        CSV.foreach(ABBREVIATIONS_FILE, headers: true).each do |row|
          abbreviated_text.gsub!(/\b#{Regexp.escape(row['full'])}\b/i, row["abbreviated"])
        end

        abbreviated_text
      end

      private

      def normalize(text)
        text.unicode_normalize(:nfkd)
            .encode("UTF-8", replace: "")
            .upcase
            .gsub(/[^A-Z0-9\s]/, "")
            .squeeze(" ")
            .strip
      end
    end
  end
end
