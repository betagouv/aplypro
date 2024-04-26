# frozen_string_literal: true

require "rails_helper"

RSpec.describe Exclusion do
  describe "validation" do
    it { is_expected.to validate_presence_of(:uai) }
    it { is_expected.to validate_uniqueness_of(:mef_code).scoped_to(:uai) }

    it "cannot be equally the whole establishment and a specific diploma" do
      create(:exclusion, :whole_establishment, uai: "FOO")

      expect { create(:exclusion, uai: "FOO", mef_code: "BAR") }.to raise_error ActiveRecord::RecordInvalid
    end
  end
end
