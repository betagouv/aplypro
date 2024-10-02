# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::CoordPaieMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:rib) { payment_request.rib }

  before do
    with_readonly_bypass(rib)
  end

  context "when the BIC ends in 'XXX'" do
    let(:xbic) { "CMCIFR2AXXX" } # https://wise.com/fr/swift-codes/countries/france/credit-mutuel-swift-code

    before { rib.update!(bic: xbic) }

    context "when it is from a non-French country" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "it")) }

      it "does not remove any characters" do
        expect(mapper.bic).to eq rib.bic
      end
    end

    context "when it is from a French country (or considered as such)" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "mc")) }

      it "removes those characters" do
        expect(mapper.bic).to eq "CMCIFR2A"
      end
    end
  end

  context "when the BIC is 8 characters long" do
    before { rib.update!(bic: rib.bic.first(8)) }

    context "when it is from a French country (or considered as such)" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "mc")) }

      it "does not touch the bic" do
        expect(mapper.bic).to eq rib.bic
      end
    end

    context "when it is from a non-French country" do
      before { rib.update!(iban: Faker::Bank.iban(country_code: "it")) }

      it "pads it to 11 characters with X's" do
        expect(mapper.bic).to eq "#{rib.bic}XXX"
      end
    end
  end

  describe "intitdest" do
    before do
      allow(ASP::RibNameSanitiser).to receive(:call).with(rib.name).and_return :result
    end

    it "returns the name processed by RibNameSanitiser" do
      expect(mapper.intitdest).to eq :result
    end
  end

  context "when the bic need a particular treatment to be accepted by the ASP" do
    context "when the rib is from the Credit Mutuel Arkea bank" do
      before { rib.update!(bic: "CMBRFR2BARK") }

      it "modify the rib as expected by the ASP" do
        expect(mapper.bic).to eq "CMBRFR2B"
      end
    end
  end
end
