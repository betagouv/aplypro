# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::DossierMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }

  describe "#numadm" do
    it "returns the schooling's DA number" do
      number = payment_request.payment.schooling.attributive_decision_number

      expect(mapper.numadm).to eq number
    end
  end
end
