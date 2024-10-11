# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Wage do
  subject(:wage) { build(:wage) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:mefstat4) }
    it { is_expected.to validate_presence_of(:ministry) }
    it { is_expected.to validate_presence_of(:daily_rate) }
    it { is_expected.to validate_presence_of(:yearly_cap) }

    it { is_expected.to validate_numericality_of(:daily_rate).only_integer.is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:yearly_cap).only_integer.is_greater_than(0) }

    context "when persisted record" do
      before { create(:wage, mefstat4: "2212") }

      it "validates uniqueness of mefstat4 scoped to ministry, daily_rate, yearly_cap, and school_year_id" do
        expect(wage).to validate_uniqueness_of(:mefstat4)
          .scoped_to(:ministry, :daily_rate, :yearly_cap, :school_year_id)
          .case_insensitive
      end
    end
  end
end
