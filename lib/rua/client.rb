module Rua
  class Client
    BASE_URL = "https://pr-api-tst-rac.omogen.in.phm.education.gouv.fr/mesirh/pp/rua/pp-grh-mes/v2"
    API_KEY = ENV.fetch("APLYPRO_RUA_API_KEY")

    attr_reader :conn

    def initialize
      @conn = connection
    end

    def agents
      conn.get("agents")
    end

    def connection
      Faraday.new(
        url: BASE_URL,
        params: {},
        headers: headers
      )
    end

    def headers
      {
        "X-Omogen-Api-Key" => API_KEY,
        "Content-Type" => "application/json"
      }
    end
  end
end
