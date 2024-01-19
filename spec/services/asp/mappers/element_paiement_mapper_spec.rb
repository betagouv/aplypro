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
end
