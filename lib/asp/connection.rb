# frozen_string_literal: true

require "net/sftp"

module ASP
  class Connection
    DEFAULT_PARAMS = {
      encryption: "aes256-cbc"
    }.freeze

    def initialize
      @connection = connection
    end

    def upload!(data, path)
      @connection.upload!(data, path)
    end

    private

    def connection
      @connection || make_connection
    end

    def make_connection
      params = connection_params

      Net::SFTP.start(params[:host], params[:user], params.except(:host, :user))
    end

    def connection_params
      %i[host port user password]
        .index_with { |param| ENV.fetch("APLYPRO_ASP_#{param.upcase}") }
        .merge(DEFAULT_PARAMS)
    end
  end
end
