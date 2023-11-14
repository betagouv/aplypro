# frozen_string_literal: true

require "rails_helper"

describe Student::AddressMappers::Fregata do
  let!(:fixture) { Rails.root.join("mock/data/fregata-students.json").read }
  let(:data) { JSON.parse(fixture) }

  describe "mapper" do
    subject { described_class.new(data.first).address_attributes }

    let(:address) { data.first["adressesApprenant"] }

    it { is_expected.to include({ postal_code: "34080" }) }
    it { is_expected.to include({ address_line1: "80 RUE DU TEST 34080 MONTPELLIER FRANCE" }) }
  end
end
