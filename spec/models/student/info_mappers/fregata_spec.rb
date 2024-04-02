# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"

describe Student::InfoMappers::Fregata do
  subject(:attributes) { described_class.new(data, "001").attributes }

  let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
  let(:data) { JSON.parse(fixture).first }

  context "when there is no address" do
    let(:data) { build(:fregata_student, :no_addresses) }

    it "does not crash" do
      expect { attributes }.not_to raise_error
    end
  end

  describe "mapper" do
    it { is_expected.to include({ address_postal_code: "34080" }) }
    it { is_expected.to include({ address_line1: "80 RUE DU TEST 34080 MONTPELLIER FRANCE" }) }
    it { is_expected.to include({ birthplace_city_insee_code: "34000" }) }
    it { is_expected.to include({ birthplace_country_insee_code: "99100" }) }
    it { is_expected.to include({ biological_sex: 1 }) }
  end

  describe "schooling attributes" do
    subject(:attributes) { described_class.new(data, "007").schooling_attributes }

    let(:data) { build(:fregata_student, :apprentice) }

    it { is_expected.to include({ status: :apprentice }) }
  end
end
