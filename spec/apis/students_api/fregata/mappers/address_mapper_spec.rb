# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Fregata::Mappers::AddressMapper do
  subject(:mapper) { described_class.new }

  let(:attributes) { build(:fregata_student) }

  it "maps correctly" do
    expect(mapper.call(attributes)).to have_key(:address_line1)
  end

  context "when there are no addresses" do
    let(:attributes) { build(:fregata_student, :no_addresses) }

    it "returns an empty hash" do
      expect(mapper.call(attributes)).to eq({})
    end
  end
end
