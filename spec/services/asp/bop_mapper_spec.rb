# frozen_string_literal: true

require "rails_helper"

describe ASP::BopMapper do
  subject(:mapper) { described_class.to_unite_suivi(ministry: ministry, private_establishment: private?) }

  let(:private?) { false }

  context "with a diploma from MASA" do
    let(:ministry) { "MASA" }

    it { is_expected.to eq "asp masa" }
  end

  context "with a diploma from Mer" do
    let(:ministry) { "mer" }

    it { is_expected.to eq "asp mer" }
  end

  context "with a diploma from MENJ" do
    let(:ministry) { "menj" }

    context "when the establishment is private" do
      let(:private?) { true }

      it "returns the right code" do
        expect(mapper).to eq "menj private"
      end
    end

    context "when the establishment is public" do
      it { is_expected.to eq "menj public" }
    end
  end
end
