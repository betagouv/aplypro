# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendAddressFixJob do
  include ActiveJob::TestHelper

  let(:server_double) { class_double(ASP::Server) }
  let(:pfmps) { create_list(:pfmp, 3, :rectified) }
  let(:pfmp_ids) { pfmps.map(&:id) }

  before do
    stub_const("ASP::Server", server_double)
    allow(server_double).to receive(:upload_file!)
  end

  it "uploads an address fix file" do
    described_class.perform_now(pfmp_ids)

    expect(server_double).to have_received(:upload_file!)
  end

  context "when no PFMPs are found" do
    it "does not upload" do
      described_class.perform_now([])

      expect(server_double).not_to have_received(:upload_file!)
    end
  end
end
