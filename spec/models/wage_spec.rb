# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Wage do
  subject(:wage) { build(:wage) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:daily_rate) }
    it { is_expected.to validate_presence_of(:mef_code) }
    it { is_expected.to validate_presence_of(:yearly_cap) }

    it { is_expected.to validate_numericality_of(:daily_rate).only_integer.is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:yearly_cap).only_integer.is_greater_than(0) }
  end
end
