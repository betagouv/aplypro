# frozen_string_literal: true

require "uri"

module StudentsApi
  module Fregata
    class Api < StudentsApi::Base
      SECRET = ENV.fetch("APLYPRO_FREGATA_SECRET")
      KEY = ENV.fetch("APLYPRO_FREGATA_KEY_ID")

      # MASA has a special encoding of the year, which happens to be the
      # current year minus 1995. 2022-2023 was year 26, which means the
      # offset is 1996. Because.
      YEAR_OFFSET = 1996

      class << self
        attr_reader :now

        def get(endpoint)
          @now = DateTime.now.httpdate

          headers = { "Authorization" => signature_header, "Date" => @now }

          client.get(endpoint, nil, headers).body
        end

        def establishment_students_endpoint(params)
          query = { rne: params.fetch(:uai),
                    anneeScolaireId: fregata_year(params.fetch(:start_year)),
                    idStatutApprenant: 2 }.to_query

          "#{base_url}/inscriptions/?#{query}"
        end

        def student_schoolings_endpoint(params)
          student_endpoint(params)
        end

        def student_endpoint(params)
          establishment_students_endpoint(
            uai: params.fetch(:uai),
            start_year: params.fetch(:start_year)
          )
        end

        private

        def fetch_student(params)
          data = super

          find_student_in_payload(data, params[:ine])
        end

        def find_student_in_payload(data, ine)
          data.find { |entry| student_mapper.new.call(entry)[:ine] == ine }
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

        def fregata_year(start_year)
          start_year - YEAR_OFFSET
        end
      end
    end
  end
end
