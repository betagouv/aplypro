# frozen_string_literal: true

require "rails_helper"

describe ASP::RnvpEnricher do
  let(:rnvp_double) { instance_double(Omogen::Rnvp) }

  before do
    allow(Omogen::Rnvp).to receive(:new).and_return(rnvp_double)
    allow(rnvp_double).to receive(:address) { |student| { id: student.id, "voieDen" => "RUE DE LA PAIX" } }
    allow(rnvp_double).to receive(:addresses) do |students|
      students.map { |s| { "id" => s.id, "voieDen" => "RUE DE LA PAIX" } }
    end
  end

  describe ".enrich_recovery_students!" do
    context "when a student had a recovery and lives in France" do
      let(:recovery_pfmp) { create(:pfmp, :rectified_with_recovery) }
      let(:payment_requests) { [create(:asp_payment_request, :sendable, pfmp: recovery_pfmp)] }

      before { recovery_pfmp.student.update!(address_country_code: "100") }

      it "enriches the student with RNVP data" do
        described_class.enrich_recovery_students!(payment_requests)

        student = payment_requests.first.student
        expect(Rails.cache.read([described_class::CACHE_KEY_PREFIX, student.id])).to be_present
      end

      it "calls RNVP" do
        described_class.enrich_recovery_students!(payment_requests)

        expect(rnvp_double).to have_received(:address).once
      end
    end

    context "when RNVP returns no data for a student" do
      let(:recovery_pfmp) { create(:pfmp, :rectified_with_recovery) }
      let(:payment_requests) { [create(:asp_payment_request, :sendable, pfmp: recovery_pfmp)] }

      before do
        recovery_pfmp.student.update!(address_country_code: "100")
        allow(rnvp_double).to receive(:address).and_return(nil)
      end

      it "raises MissingRnvpDataError" do
        expect { described_class.enrich_recovery_students!(payment_requests) }
          .to raise_error(ASP::Errors::MissingRnvpDataError)
      end
    end

    context "when the number of students exceeds the batch threshold" do
      let(:pfmps) { create_list(:pfmp, described_class::BATCH_THRESHOLD + 1, :rectified_with_recovery) }
      let(:payment_requests) do
        pfmps.map { |pfmp| create(:asp_payment_request, :sendable, pfmp: pfmp) }
             .tap { |prs| prs.each { |pr| pr.student.update!(address_country_code: "100") } }
      end

      it "calls addresses once for all students" do
        described_class.enrich_recovery_students!(payment_requests)

        expect(rnvp_double).to have_received(:addresses).exactly(1).time
        expect(rnvp_double).not_to have_received(:address)
      end
    end

    context "when two payment requests share the same student" do
      let(:schooling) { create(:schooling) }
      let(:first_pfmp) { create(:pfmp, :rectified_with_recovery, schooling:) }
      let(:second_pfmp) { create(:pfmp, :rectified_with_recovery, schooling:) }
      let(:payment_requests) do
        ids = [create(:asp_payment_request, :sendable, pfmp: first_pfmp),
               create(:asp_payment_request, :sendable, pfmp: second_pfmp)].map(&:id)
        ASP::PaymentRequest.where(id: ids).includes(:student).to_a
      end

      before { schooling.student.update!(address_country_code: "100") }

      it "calls RNVP exactly once for the shared student" do
        described_class.enrich_recovery_students!(payment_requests)

        expect(rnvp_double).to have_received(:address).with(schooling.student).once
      end

      it "caches RNVP data for the shared student" do
        described_class.enrich_recovery_students!(payment_requests)

        expect(Rails.cache.read([described_class::CACHE_KEY_PREFIX, schooling.student.id])).to be_present
      end
    end
  end
end
