# frozen_string_literal: true

module Omogen
  class Rnvp < Omogen::Base
    ADDRESSES_LIMIT = 1000
    TIMEOUT_LIMIT = 600

    def address(student)
      return nil if student.nil? || !student.lives_in_france?

      @job_uuid = nil
      api_post("address", address_mapper(student))
    end

    def addresses(students)
      return [] if students.blank?

      students.each_slice(ADDRESSES_LIMIT).flat_map do |group|
        french_addresses = group.select(&:lives_in_france?).map { |s| address_mapper(s) }
        @job_uuid = nil
        send_addresses(french_addresses)
      end
    end

    private

    def send_addresses(addresses)
      Timeout.timeout(TIMEOUT_LIMIT) do
        loop do
          result = api_post("batch", { addresses: addresses })
          return [] if result.nil?

          return result["data"]["rnvpAddresses"] if result["data"].present?

          sleep result["ticket"]["estimatedWaitingTimeSeconds"].to_i
          @job_uuid = result["ticket"]["jobUUID"]
        end
      end
    rescue Timeout::Error
      Rails.logger.error("  ⚠ Time out ! No support from RNVP API after waiting #{TIMEOUT_LIMIT} seconds.")
      []
    end

    def address_mapper(student)
      {
        id: student.id,
        ligne2: student.address_line1,
        ligne3: student.address_line2,
        codePostal: student.address_postal_code,
        codeInsee: student.address_city_insee_code,
        localite: student.address_city
      }
    end

    def api_post(resource, data)
      response = resource_connection.post(resource, data)

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("  ⚠ Error calling RNVP API on '/#{resource}' with #{data} : #{e.message}")
      nil
    end

    def base_url
      ENV.fetch("RNVP_RESOURCE_BASE_URL")
    end

    def headers
      super.merge!(
        "client-uuid" => ENV.fetch("RNVP_CLIENT_HEADER"),
        "job-uuid" => @job_uuid
      ).compact
    end

    def auth_url
      ENV.fetch("RNVP_OMOGEN_TOKEN_URL")
    end

    def auth_params
      {
        grant_type: ENV.fetch("RNVP_OMOGEN_GRANT_TYPE"),
        client_id: ENV.fetch("RNVP_OMOGEN_CLIENT_ID"),
        client_secret: ENV.fetch("RNVP_OMOGEN_CLIENT_SECRET")
      }
    end
  end
end
