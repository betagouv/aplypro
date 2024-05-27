# frozen_string_literal: true

require "rails_helper"

require "./mock/apis/factories/api_student"

describe Student::InfoMappers::Fregata do
  subject(:attributes) { described_class.new(data, "001").attributes }

  let(:fixture) do
    build_list(
      :fregata_student,
      1,
      :male,
      address_line1: "one",
      address_line2: "two",
      address_postal_code: "test zipcode",
      birthplace_city_insee_code: "test birthplace zipcode",
      birthplace_country_insee_code: "test birthplace country code"
    ).to_json
  end

  let(:data) { JSON.parse(fixture).first }

  context "when there is no address" do
    let(:data) { build(:fregata_student, :no_addresses) }

    it "does not crash" do
      expect { attributes }.not_to raise_error
    end
  end

  describe "mapper" do
    it { is_expected.to include({ address_postal_code: "test zipcode" }) }
    it { is_expected.to include({ address_line1: "one two 34080 MONTPELLIER FRANCE" }) }
    it { is_expected.to include({ birthplace_city_insee_code: "test birthplace zipcode" }) }
    it { is_expected.to include({ birthplace_country_insee_code: "test birthplace country code" }) }
    it { is_expected.to include({ biological_sex: 1 }) }
  end

  describe "schooling attributes" do
    subject(:attributes) { described_class.new(data, "007").schooling_attributes }

    let(:data) { build(:fregata_student, :apprentice) }

    it { is_expected.to include({ status: :apprentice }) }
  end
end
