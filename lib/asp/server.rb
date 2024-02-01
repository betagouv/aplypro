# frozen_string_literal: true

module ASP
  class Server
    DROP_FOLDER = "/depot"

    class << self
      def drop_file!(io:, path:)
        Connection.new.upload!(StringIO.new(io), File.join(DROP_FOLDER, path))
      end
    end
  end
end
