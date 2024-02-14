# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::CoordPaieMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:rib) { payment_request.student.rib }

  context "when the BIC ends in 'XXX'" do
    before { rib.update!(bic: "ASTPGB2LXXX") }

    it "removes those characters" do
      expect(mapper.bic).to eq "ASTPGB2L"
    end
  end
end
