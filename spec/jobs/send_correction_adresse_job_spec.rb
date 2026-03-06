# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendCorrectionAdresseJob do
  include ActiveJob::TestHelper

  let(:request_double) { instance_double(ASP::Request, send_correction_adresse!: nil) }
  let(:pfmps) { create_list(:pfmp, 3, :rectified) }
  let(:pfmp_ids) { pfmps.map(&:id) }

  before do
    allow(ASP::Request).to receive(:create!).and_return(request_double)
  end

  it "creates a correction adresse ASP request" do
    described_class.perform_now(pfmp_ids)

    expect(ASP::Request).to have_received(:create!).with(correction_adresse: true)
    expect(request_double).to have_received(:send_correction_adresse!)
  end

  context "when no PFMPs are found" do
    it "does not create an ASP request" do
      described_class.perform_now([])

      expect(ASP::Request).not_to have_received(:create!)
    end
  end
end
