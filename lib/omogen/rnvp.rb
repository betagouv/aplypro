# frozen_string_literal: true

module Omogen
  class Rnvp < Omogen::Base
    ADDRESSES_LIMIT = 1000

    def address(student)
      return nil if student.nil? || !student.lives_in_france?

      api_post("address", address_mapper(student))
    end

    def addresses(students)
      return [] if students.blank?

      students.each_slice(ADDRESSES_LIMIT).each do |grouped_students|
        addresses = []

        grouped_students.each do |student|
          next unless student.lives_in_france?

          addresses << address_mapper(student)
        end

        data = { addresses: addresses }

        result = api_post("batch", data)

        Rails.logger.info(send_addresses(data, result))
      end
    end

    private

    def send_addresses(addresses, result)
      if result["data"].nil?
        sleep 1000 * result["ticket"]["estimatedWaitingTimeSeconds"].to_i

        headers.merge!("job-uuid" => result["ticket"]["jobUUID"])

        send_addresses(addresses, api_post("batch", addresses))
      else
        result["data"]["rnvpAddresses"]
      end
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
    end

    def base_url
      ENV.fetch("RNVP_RESOURCE_BASE_URL")
    end

    def headers
      super.merge!("client-uuid" => ENV.fetch("RNVP_CLIENT_HEADER"))
    end
  end
end
