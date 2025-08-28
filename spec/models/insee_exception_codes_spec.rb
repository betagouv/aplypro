# frozen_string_literal: true

require "rails_helper"

RSpec.describe InseeExceptionCodes do
  describe "validation" do
    subject { create(:insee_exception_codes) }

    it { is_expected.to validate_presence_of(:code_type) }
    it { is_expected.to validate_presence_of(:entry_code) }
    it { is_expected.to validate_presence_of(:exit_code) }

    it { is_expected.to validate_uniqueness_of(:entry_code) }

    it { is_expected.to validate_length_of(:entry_code).is_at_least(5).is_at_most(5) }
    it { is_expected.to validate_length_of(:exit_code).is_at_least(5).is_at_most(5) }
  end

  describe "#transform_insee_code" do
    subject { described_class.transform_insee_code(entry_code, code_type) }

    let(:entry_code) { "1234A" }
    let(:code_type) { "address" }

    before { create(:insee_exception_codes) }

    context "when the code_type and the entry_code are valid" do
      it { is_expected.to eq "54321" }
    end

    context "when the entry_code does not match" do
      let(:entry_code) { "98765" }

      it { is_expected.to eq entry_code }
    end

    context "when the code_type does not match" do
      let(:code_type) { "birthdate" }

      it { is_expected.to eq entry_code }
    end
  end
end
