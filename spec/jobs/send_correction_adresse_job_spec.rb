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
    allow(rnvp_double).to receive(:address) { |student| { id: student.id } }
    allow(rnvp_double).to receive(:addresses) { |students| students.map { |s| { id: s.id } } }
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

    it "does not call RNVP" do
      described_class.perform_now([])

      expect(Omogen::Rnvp).not_to have_received(:new)
    end
  end

  context "when the number of students is below the batch threshold" do
    it "calls address once per student" do
      described_class.perform_now(pfmp_ids)

      expect(rnvp_double).to have_received(:address).exactly(pfmps.count).times
      expect(rnvp_double).not_to have_received(:addresses)
    end

    context "when a student has no RNVP data" do
      before { allow(rnvp_double).to receive(:address).and_return(nil) }

      it "raises MissingRnvpDataError" do
        expect { described_class.perform_now(pfmp_ids) }.to raise_error(ASP::Errors::MissingRnvpDataError)
      end
    end
  end

  context "when the number of students exceeds the batch threshold" do
    let(:pfmps) { create_list(:pfmp, described_class::RNVP_STUDENT_BATCH_THRESHOLD + 1, :rectified) }

    it "calls addresses once for all students" do
      described_class.perform_now(pfmp_ids)

      expect(rnvp_double).to have_received(:addresses).exactly(1).time
      expect(rnvp_double).not_to have_received(:address)
    end

    context "when a student has no RNVP data" do
      before { allow(rnvp_double).to receive(:addresses).and_return([]) }

      it "raises MissingRnvpDataError" do
        expect { described_class.perform_now(pfmp_ids) }.to raise_error(ASP::Errors::MissingRnvpDataError)
      end
    end
  end

  context "when a student has two PFMPs in the list" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:schooling) { create(:schooling) }
    let(:student) { schooling.student }
    let(:pfmps) { create_list(:pfmp, 2, :rectified, schooling:) }

    it "sends the student only once" do
      described_class.perform_now(pfmp_ids)

      expect(rnvp_double).to have_received(:address).with(student).once
    end
  end
end
