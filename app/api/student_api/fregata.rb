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

      params = { rne: @establishment.uai, anneeScolaireId: SCHOOL_YEAR }
      headers = { "Authorization" => signature_header, "Date" => @now }

      client.get(endpoint, params, headers).body
    end

    def endpoint
      base_url
    end

    private

    def client
      @client ||= Faraday.new do |f|
        f.response :json
      end
    end

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
