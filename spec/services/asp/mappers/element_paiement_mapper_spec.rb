# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::ElementPaiementMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:schooling) { create(:schooling) }

  let(:payment_request) { create(:asp_payment_request, :ready) }

  before do
    payment_request.update!(schooling: schooling)
  end

  describe "usprinc" do
    subject { mapper.usprinc }

    context "when the MEF is from the MENJ" do
      context "when the establishment is private" do
        before { allow(schooling).to receive(:bop_code).and_return :menj_private }

        it { is_expected.to eq "menj private" }
      end

      context "when the establishment is public" do
        before { allow(schooling).to receive(:bop_code).and_return :menj_public }

        it { is_expected.to eq "menj public" }
      end
    end

    context "when the MEF is from the MASA" do
      before { allow(schooling).to receive(:bop_code).and_return :masa }

      it { is_expected.to eq "asp masa" }
    end
  end

  describe "codeobjet" do
    it "is normally equal to VERSE001" do
      expect(mapper.codeobjet).to eq "VERSE001"
    end
  end
end
