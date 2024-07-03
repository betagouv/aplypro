# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolYear do
  subject(:school_year) { build(:school_year) }

  describe "associations" do
    it { is_expected.to have_many(:classes) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_year) }
    it { is_expected.to validate_uniqueness_of(:start_year) }
  end

  describe "#current" do
    it "select the last year" do
      expect(described_class.current.start_year).to eq 2024
    end
  end
end
