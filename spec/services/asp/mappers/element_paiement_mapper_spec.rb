# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::ElementPaiementMapper do
  subject(:mapper) { described_class.new(payment) }

  let(:student) { create(:student, :with_all_asp_info) }
  let(:schooling) { create(:schooling, student: student) }
  let(:payment) { create(:payment, schooling: schooling) }

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

    context "when the PFMP has a previous payment" do
      before do
        create(:payment, pfmp: payment.pfmp, created_at: Date.yesterday)
      end

      it "is accounts for it" do
        expect(mapper.codeobjet).to eq "VERSE002"
      end
    end
  end
end
