# frozen_string_literal: true

require "rails_helper"

RSpec.describe Classe do
  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:mef).class_name("Mef") }
    it { is_expected.to have_many(:students).order("last_name") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:start_year) }
    it { is_expected.to validate_numericality_of(:start_year).only_integer.is_greater_than_or_equal_to(2023) }
  end

  describe ".current" do
    let(:last_year) { create(:classe, start_year: 2020) }
    let(:next_year) { create(:classe, start_year: 2024) }
    let(:current) { create(:classe, start_year: 2023) }

    before do
      allow(ENV)
        .to receive(:fetch)
        .with("APLYPRO_SCHOOL_YEAR")
        .and_return("2023")
    end

    it "only returns the classes that started the same year as APLYPRO_SCHOOL_YEAR" do
      expect(described_class.current).to contain_exactly(current)
    end
  end
end
