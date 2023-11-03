# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Mef do
  subject(:mef) { build(:mef) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:ministry) }
  it { is_expected.to validate_presence_of(:mefstat11) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:short) }

  describe "bop_code" do
    context "when the mef.ministry is no MENJ" do
      let(:mef) { build(:mef, ministry: "masa") }
      let(:establishment) { create(:establishment) }

      it "returns the ministry" do
        expect(mef.bop_code(establishment)).to eq "masa"
      end
    end

    context "when the mef.ministry is MENJ" do
      let(:mef) { build(:mef, ministry: "menj") }

      context "when the establishment status contract is 'without subject'" do
        let(:establishment) { create(:establishment, private_contract_type_code: "99") }

        it "returns the Public MENJ BOP code" do
          expect(mef.bop_code(establishment)).to eq "enpu"
        end
      end

      context "when the establishment status contract is an 'allowed private'" do
        let(:establishment) { create(:establishment, private_contract_type_code: "31") }

        it "returns the Public MENJ BOP code" do
          expect(mef.bop_code(establishment)).to eq "enpr"
        end
      end

      context "when the establishment status contract is an 'unallowed_private'" do
        let(:establishment) { create(:establishment, private_contract_type_code: "10") }

        it "returns the Public MENJ BOP code" do
          expect { mef.bop_code(establishment) }.to raise_error IdentityMappers::Errors::UnallowedPrivateEstablishment
        end
      end
    end
  end
end
