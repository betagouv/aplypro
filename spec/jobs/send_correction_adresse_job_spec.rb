# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendCorrectionAdresseJob do
  include ActiveJob::TestHelper

  let(:request_double) { instance_double(ASP::Request, send_correction_adresse!: nil) }
  let(:rnvp_double) { instance_double(Omogen::Rnvp) }
  let(:pfmps) { create_list(:pfmp, 3, :rectified) }
  let(:pfmp_ids) { pfmps.map(&:id) }

  before do
    allow(ASP::Request).to receive(:create!).and_return(request_double)
    allow(Omogen::Rnvp).to receive(:new).and_return(rnvp_double)
    allow(rnvp_double).to receive(:addresses).and_return([{}])
  end

  it "creates a correction adresse ASP request" do
    described_class.perform_now(pfmp_ids)

    expect(ASP::Request).to have_received(:create!).with(correction_adresse: true)
    expect(request_double).to have_received(:send_correction_adresse!)
  end

  it "calls RNVP one time for all students" do
    described_class.perform_now(pfmp_ids)

    expect(rnvp_double).to have_received(:addresses).exactly(1).time
  end

  context "when no PFMPs are found" do
    it "does not create an ASP request" do
      described_class.perform_now([])

      expect(ASP::Request).not_to have_received(:create!)
    end

    it "does not call RNVP" do
      described_class.perform_now([])

      expect(Omogen::Rnvp).not_to have_received(:new)
    end
  end
end
