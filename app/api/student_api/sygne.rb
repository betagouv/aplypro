# frozen_string_literal: true

module StudentApi
  class Sygne < Base
    def identifier
      "SYGNE"
    end

    def endpoint
      base_url % @establishment.uai
    end

    def fetch_and_parse!
      data = fetch!

      parse!(data)
    end

    def fetch!
      with_token = client.access_token!

      with_token.get(endpoint).body
    end

    def parse!(data)
      method = "parse_on_#{criteria}!"

      send(method, data)
    end

    def criteria
      ENV.fetch("APLYPRO_SYGNE_USE_MEFSTAT4").present? ? "mefstat4" : "mef"
    end

    def parse_on_mefstat4!(data)
      mefs = Mef.all # this is awful but it's temporary

      classes = data.group_by { |s| [s["classe"], s["niveau"]] }

      classes.each do |classe, eleves|
        label, niveau = classe

        m = mefs.find { |mef| mef.mefstat4 == niveau }

        klass = @establishment.classes.find_or_create_by!(label:, mef: m)

        parse_eleves!(klass, eleves)
      end
    end

    def parse_on_mef!(data)
      classes = data.group_by { |s| [s["classe"], s["mef"]] }

      classes.each do |classe, eleves|
        label, mef = classe

        m = Mef.find_by!(code: mef)

        klass = @establishment.classes.find_or_create_by!(label:, mef: m)

        parse_eleves!(klass, eleves)
      end
    end

    def parse_eleves!(klass, eleves)
      eleves.map do |attributes|
        Student.find_or_initialize_by(ine: attributes["ine"]) do |student|
          student.update!(Student.map_sygne_hash(attributes).merge({ classe: klass }))
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
  end
end
