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

  describe "bop" do
    subject(:code) { mef.bop(establishment) }

    let(:establishment) { instance_double(Establishment) }

    context "when the mef.ministry is not MENJ" do
      before { mef.update!(ministry: "masa") }

      it "returns the ministry" do
        expect(code).to eq :masa
      end
    end

    context "when the mef.ministry is MENJ" do
      before { mef.update!(ministry: "menj") }

      %i[public private].each do |type|
        context "when the establishment is #{type}" do
          before { allow(establishment).to receive(:contract_type).and_return(type) }

          it { is_expected.to eq :"menj_#{type}" }
        end
      end
    end
  end

  describe "#wage" do
    context "when there is one wage with mefstat4 & ministry" do
      let!(:wage) { create(:wage, mefstat4: mef.mefstat4, ministry: mef.ministry) }

      it "returns the only wage" do
        expect(mef.wage).to eq wage
      end
    end

    context "when there are several wages with mefstat4 & ministry" do
      let!(:correct_wage) { create(:wage, mefstat4: mef.mefstat4, ministry: mef.ministry, mef_codes: [mef.code]) }

      before do
        create(:wage, mefstat4: mef.mefstat4, ministry: mef.ministry, mef_codes: %w[many codes])
      end

      it "returns the correct wage" do
        expect(mef.wage).to eq correct_wage
      end
    end
  end

  describe "associated wage of mef in seed" do
    {
      "2712101021" => { daily_rate: 10, yearly_cap: 450 },
      "2712101022" => { daily_rate: 15, yearly_cap: 675 },
      "2762100132" => { daily_rate: 15, yearly_cap: 900 },
      "2532210311" => { daily_rate: 15, yearly_cap: 1350 }
    }.each do |mef_code, amounts|
      context mef_code.to_s do
        let(:wage) { described_class.find_by(code: mef_code).wage }

        it "has daily_rate = #{amounts[:daily_rate]}" do
          expect(wage.daily_rate).to eq amounts[:daily_rate]
        end

        it "#{mef_code} has yearly_cap = #{amounts[:yearly_cap]}" do
          expect(wage.yearly_cap).to eq amounts[:yearly_cap]
        end
      end
    end
  end

  describe "with_wage scope" do
    let(:mefs) { create_list(:mef, 4) }
    let(:wages) { mefs.map(&:wage) }
    let(:mefs_collection) { described_class.where(id: mefs.pluck(:id)) }

    before do
      wages[0].update(mef_codes: [mefs[0].code, "123", "456"])
      wages[1].update(mef_codes: ["123", mefs[1].code, "456"])
      wages[2].update(mef_codes: ["123", "456", mefs[2].code])
    end

    it "joins the correct wages" do
      expect(mefs_collection.with_wages.pluck(:"wages.id")).to match_array(wages.pluck(:id))
    end
  end
end
