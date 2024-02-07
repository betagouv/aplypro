# frozen_string_literal: true

require "cucumber/rspec/doubles"

TEMP_ASP_DIR = "tmp/mock_asp"

def mock_sftp!
  FileUtils.mkdir_p(TEMP_ASP_DIR)

  asp_server_double = class_double(ASP::Server)

  allow(asp_server_double).to receive(:drop_file!)
  allow(asp_server_double).to receive(:get_all_files!).and_return(TEMP_ASP_DIR)

  stub_const("ASP::Server", asp_server_double)
end

Before do
  mock_sftp!
end
