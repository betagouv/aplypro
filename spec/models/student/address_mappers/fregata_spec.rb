# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"

describe Student::AddressMappers::Fregata do
  subject { described_class.new(data).address_attributes }

  let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
  let(:data) { JSON.parse(fixture).first }

  context "when there is no address" do
    let(:data) { build(:fregata_student, :no_addresses) }

    it { is_expected.to be_nil }
  end

  describe "mapper" do
    let(:address) { data.first["adressesApprenant"] }

    it { is_expected.to include({ address_postal_code: "34080" }) }
    it { is_expected.to include({ address_line1: "80 RUE DU TEST 34080 MONTPELLIER FRANCE" }) }
  end
end
