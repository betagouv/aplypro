# frozen_string_literal: true

require "rails_helper"

RSpec.describe InseeExceptionCodes do
  describe "validation" do
    subject { create(:insee_exception_codes) }

    it { is_expected.to validate_presence_of(:code_type) }
    it { is_expected.to validate_presence_of(:entry_code) }
    it { is_expected.to validate_presence_of(:exit_code) }

    it { is_expected.to validate_uniqueness_of(:entry_code) }

    it { is_expected.to validate_length_of(:entry_code).is_equal_to(5) }
    it { is_expected.to validate_length_of(:exit_code).is_equal_to(5) }
  end

  describe "#transform_insee_code" do
    before do
      create(:insee_exception_codes)
      Rails.cache.clear
    end

    it "returns the exit_code when mapping exists" do
      expect(described_class.transform_insee_code("1234A", "address")).to eq("54321")
    end

    it "returns the entry_code when no mapping exists" do
      expect(described_class.transform_insee_code("99999", "address")).to eq("99999")
    end
  end

  describe "#mapping" do
    before { Rails.cache.clear }

    it "updates mapping after create and destroy" do
      expect(described_class.mapping.keys).not_to include(%w[address 1234A])

      exception_code = create(:insee_exception_codes)
      expect(described_class.mapping.keys).to include(%w[address 1234A])

      exception_code.destroy!
      expect(described_class.mapping.keys).not_to include(%w[address 1234A])
    end

    it "does not hit the database when mapping is cached" do
      create(:insee_exception_codes)
      described_class.mapping

      allow(ActiveRecord::Base.connection).to receive(:exec_query).and_call_original

      described_class.mapping

      expect(ActiveRecord::Base.connection).not_to have_received(:exec_query)
    end
  end
end
