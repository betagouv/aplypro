# frozen_string_literal: true

require "uri"

module StudentApi
  class Fregata < Base
    SECRET = ENV.fetch("APLYPRO_FREGATA_SECRET")
    KEY = ENV.fetch("APLYPRO_FREGATA_KEY_ID")

    # for some reason MASA has a strange year-encoding system that
    # makes 2023 = 26, we'll have to model that at some point
    SCHOOL_YEAR = 26

    attr_reader :now

    def fetch!
      @now = DateTime.now.httpdate

      Faraday.get(
        endpoint,
        { rne: @establishment.uai, anneeScolaireId: SCHOOL_YEAR },
        { "Authorization" => signature_header, "Date" => @now }
      )
    end

    def endpoint
      base_url
    end

    private

    def signature
      str = "date: #{@now}"

      encoded = OpenSSL::HMAC.digest("SHA1", SECRET, str)

      Base64.urlsafe_encode64(encoded)
    end

    def signature_header
      params = {
        keyId: KEY,
        algorithm: "hmac-sha1",
        signature: signature
      }

      sig = params.map { |k, v| [k, v].join("=") }.join(",")

      "Signature #{sig}"
    end
  end
end
