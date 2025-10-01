# frozen_string_literal: true

class RnvpApi
  class << self
    def fetch!(student)
      response = connection.post do |req|
        req.body = {
          ligne2: student.address_line1,
          ligne3: student.address_line2,
          codeInsee: student.address_city_insee_code,
        }.to_json
      end

      response.body # TODO: Ne marche pas avec la vraie API pour l'instant !
    end

    private

    def connection
      Faraday.new(
        url: ENV.fetch("APLYPRO_RNVP_URL"),
        headers: {
          "Content-Type" => "application/json",
          "X-Omogen-Api-Key" => ENV.fetch("APLYPRO_RNVP_SECRET")
        }
      ) do |f|
        f.response :json
      end
    end
  end
end
