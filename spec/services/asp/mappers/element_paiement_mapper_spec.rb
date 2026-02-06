# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::ElementPaiementMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:schooling) { payment_request.schooling }

  let(:payment_request) { create(:asp_payment_request, :ready) }

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

  describe "objetecheance" do
    it "returns the PFMP start date formatted as YYYYMM" do
      payment_request.pfmp.update!(start_date: Date.new(2025, 9, 25))
      expect(mapper.objetecheance).to eq "202509"
    end
  end
end
