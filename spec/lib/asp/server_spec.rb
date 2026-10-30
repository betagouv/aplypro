# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::Server do
  describe "#connection" do
    it "allows the ssh-rsa host key required by the ASP server" do
      allow(Net::SFTP).to receive(:start)

      described_class.new.connection

      expect(Net::SFTP).to have_received(:start).with(
        ENV.fetch("APLYPRO_ASP_FTP_HOST"),
        ENV.fetch("APLYPRO_ASP_FTP_USER"),
        hash_including(host_key: ["ssh-rsa"])
      )
    end
  end
end
