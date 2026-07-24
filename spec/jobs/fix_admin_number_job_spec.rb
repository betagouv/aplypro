# frozen_string_literal: true

require "rails_helper"

describe FixAdminNumberJob do
  subject(:perform) { described_class.perform_now(pfmp.id) }

  let(:payment_request) { create(:asp_payment_request, :sent) }
  let(:pfmp) { payment_request.pfmp }
  let(:old_number) { pfmp.reload.administrative_number }
  let(:prefix) { old_number[0..-3] }

  before { payment_request.mark_rejected!("Motif rejet" => "Le numéro administratif n'est pas unique") }

  it "recomputes and persists a fresh administrative_number" do
    expect { perform }.to change { pfmp.reload.administrative_number }
      .from(old_number)
      .to("#{prefix}02")
  end

  it "resubmits the pfmp for payment" do
    perform

    expect(pfmp.reload.latest_payment_request).to be_in_state(:ready)
  end

  context "when other PFMPs already exist on the same schooling" do
    before { create(:pfmp, schooling: pfmp.schooling) }

    it "picks a suffix higher than the PFMP count" do
      expect { perform }.to change { pfmp.reload.administrative_number }.to("#{prefix}03")
    end
  end

  context "when the current suffix is already at the maximum" do
    before { pfmp.update!(administrative_number: "#{prefix}99") }

    it "raises instead of writing an invalid suffix" do
      expect { perform }.to raise_error(described_class::SuffixExhaustedError)
    end
  end
end
