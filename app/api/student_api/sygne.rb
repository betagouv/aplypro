# frozen_string_literal: true

module StudentApi
  class Sygne < Base
    def fetch_and_parse!
      data = fetch!

      parse!(data)
    end

    def fetch!
      with_token = client.access_token!

      with_token.get(endpoint).body
    end

    def parse!(data)
      classes = data.group_by { |s| [s["classe"], s["niveau"]] }

      classes.map do |classe, eleves|
        label, mefstat = classe

        @establishment
          .classes
          .find_or_create_by(
            label:,
            mefstat: Mefstat.find_or_create_by(code: mefstat)
          )
          .tap do |c|
          c.students << eleves.map { |e| Student.from_sygne_hash(e) }
        end
      end
    end

    def client
      Rack::OAuth2::Client.new(
        identifier: ENV.fetch("APLYPRO_SYGNE_CLIENT_ID"),
        secret: ENV.fetch("APLYPRO_SYGNE_SECRET"),
        token_endpoint: ENV.fetch("APLYPRO_SYGNE_TOKEN_URL")
      )
    end

    def identifier
      "SYGNE"
    end
  end
end
