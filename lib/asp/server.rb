# frozen_string_literal: true

module ASP
  class Server
    DROP_FOLDER = ENV.fetch("APLYPRO_ASP_FTP_DROP_FOLDER")
    READ_FOLDER = ENV.fetch("APLYPRO_ASP_FTP_READ_FOLDER")

    class << self
      def drop_file!(io:, path:)
        instance.connection.upload!(StringIO.new(io), File.join(DROP_FOLDER, path))
      end

      def get_all_files! # rubocop:disable Naming/AccessorMethodName
        Dir
          .mktmpdir("aplypro_asp")
          .tap do |dir|
          instance.connection.download!(READ_FOLDER, dir, recursive: true)
        end
      end

      def remove_file!(path:)
        instance.connection.remove!(File.join(READ_FOLDER, path))
      end

      def instance
        @instance ||= new
      end
    end

    def connection
      @connection || make_connection
    end

    private

    def make_connection
      params = connection_params

      Net::SFTP.start(params[:host], params[:user], params.except(:host, :user))
    end

    def connection_params
      %i[host port user password]
        .index_with { |param| ENV.fetch("APLYPRO_ASP_FTP_#{param.upcase}") }
        .tap do |params|
        params.merge(encryption: "aes256-cbc") if Rails.env.production?
      end
    end
  end
end
