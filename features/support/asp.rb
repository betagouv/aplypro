# frozen_string_literal: true

require "cucumber/rspec/doubles"
require "./mock/factories/asp"

TEMP_ASP_DIR = "tmp/mock_asp"

class FakeServer
  class << self
    def drop_file!(io:, path:); end

    def get_all_files! # rubocop:disable Naming/AccessorMethodName
      TEMP_ASP_DIR
    end

    def remove_file!(filename:)
      File.delete(File.join(TEMP_ASP_DIR, filename))
    end
  end
end

def mock_sftp!
  FileUtils.mkdir_p(TEMP_ASP_DIR)

  stub_const("ASP::Server", FakeServer)
end

Before do
  mock_sftp!
end

After do
  FileUtils.rm_rf(TEMP_ASP_DIR)

  # remove the requests to avoid hitting the 10-per-day limit we have
  # in our production environment
  ASP::Request.destroy_all
end
