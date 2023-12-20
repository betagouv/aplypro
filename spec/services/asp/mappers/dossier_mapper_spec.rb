# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::DossierMapper do
  subject(:mapper) { described_class.new(payment) }

  let(:student) { create(:student) }
  let(:payment) { create(:payment) }

  before { payment.pfmp.update!(student: student) }

  describe "#numadm" do
    it "returns the schooling's DA number" do
      expect(mapper.numadm).to eq payment.schooling.attributive_decision_number
    end
  end
end
