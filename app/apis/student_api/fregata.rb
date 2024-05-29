# frozen_string_literal: true

require "uri"

module StudentApi
  class Fregata < Base
    SECRET = ENV.fetch("APLYPRO_FREGATA_SECRET")
    KEY = ENV.fetch("APLYPRO_FREGATA_KEY_ID")

    # MASA has a special encoding of the year, which happens to be the
    # current year minus 1995. 2022-2023 was year 26, which means the
    # offset is 1996. Because.
    YEAR_OFFSET = 1996

    attr_reader :now

    def fetch!
      @now = DateTime.now.httpdate

      params = { rne: @uai, anneeScolaireId: fregata_year }
      headers = { "Authorization" => signature_header, "Date" => @now }

      client.get(endpoint, params, headers).body
    end

    def fetch_student_data!(ine)
      find_student_in_payload(ine)
    end

    def endpoint
      base_url
    end

    private

    def find_student_in_payload(ine)
      m = mapper.new(response, @establishment)

      response.find { |entry| m.map_student_attributes(entry)[:ine] == ine }
    end

    def client
      @client ||= Faraday.new do |f|
        f.response :json
        f.response :raise_error
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

    def fregata_year
      Aplypro::SCHOOL_YEAR - YEAR_OFFSET
    end
  end
end
