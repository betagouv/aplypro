# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::ElementPaiementMapper do
  subject(:mapper) { described_class.new(payment) }

  let(:student) { create(:student) }
  let(:payment) { create(:payment) }

  before { payment.pfmp.update!(student: student) }

  describe "usprinc" do
    before { allow(ASP::BopMapper).to receive(:to_unite_suivi).and_return "ustest" }

    it "maps to the BopMapper value" do
      expect(mapper.usprinc).to eq "ustest"
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
