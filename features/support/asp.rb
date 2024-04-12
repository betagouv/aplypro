# frozen_string_literal: true

require "cucumber/rspec/doubles"
require "./mock/factories/asp"

TEMP_ASP_DIR = "tmp/mock_asp"

def mock_sftp!
  FileUtils.mkdir_p(TEMP_ASP_DIR)

  asp_server_double = class_double(ASP::Server)

  allow(asp_server_double).to receive(:drop_file!)
  allow(asp_server_double).to receive(:get_all_files!).and_return(TEMP_ASP_DIR)
  allow(asp_server_double).to receive(:remove_file!)

  stub_const("ASP::Server", asp_server_double)
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
