# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::ElementPaiementMapper do
  subject(:mapper) { described_class.new(payment) }

  let(:student) { create(:student) }
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
    context "when the student has no successful payments yet" do
      it "marks it as the first one" do
        expect(mapper.codeobjet).to eq "VERSE001"
      end
    end

    context "when the student has previous payments" do
      before { create_list(:payment, 3, :successful, pfmp: payment.pfmp) }

      it "adds the correct index" do
        expect(mapper.codeobjet).to eq "VERSE004"
      end
    end
  end
end
