# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rib do
  subject(:rib) { create(:rib) }

  describe "associations" do
    it { is_expected.to belong_to(:student) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:iban) }
    it { is_expected.to validate_presence_of(:bic) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:student_id).scoped_to(:archived_at) }

    context "when the IBAN is from outside the SEPA zone" do
      subject(:rib) { build(:rib, iban: Faker::Bank.iban(country_code: "br")) }

      it { is_expected.not_to be_valid }
    end

    context "when there are extra spaces" do
      before { rib.iban = "     #{rib.iban}" }

      it "validates despite them" do
        expect(rib).to be_valid
      end
    end

    context "when it's lowercased" do
      before { rib.iban = rib.iban.downcase }

      it "validates anyway" do
        expect(rib).to be_valid
      end
    end
  end

  describe "normalization" do
    subject(:spaced) { create(:rib, bic: "   #{rib.bic.downcase}  ", iban: "   #{rib.iban.downcase}  ") }

    %i[bic iban].each do |attr|
      it "strips the #{attr}" do
        expect(spaced[attr]).to eq rib[attr].upcase
      end
    end
  end
end
