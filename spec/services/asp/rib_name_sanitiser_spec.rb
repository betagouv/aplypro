# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::RibNameSanitiser do
  subject(:result) { described_class.new.call(name) }

  context "when the RIB has space-like characters" do
    let(:name) { "O’Connell" }

    it "substitutes them with a normal space" do
      expect(result).to eq "O'Connell"
    end
  end

  context "when the RIB has subsitutable characters" do
    let(:name) { "O–Connell>>" }

    it "replaces them" do
      expect(result).to eq "O-Connell"
    end
  end

  context "when the RIB has irrelevant characters" do
    let(:name) { "FOO^BAR" }

    it "deletes them" do
      expect(result).to eq "FOOBAR"
    end
  end

  context "when the RIB has extra spaces" do
    let(:name) { "Some      long name" }

    it "removes them" do
      expect(result).to eq "Some long name"
    end
  end

  context "when the RIB has unknown, invalid characters" do
    let(:name) { "Johnny 🔥 Cash" }

    it "removes them" do
      expect(result).to eq "Johnny Cash"
    end
  end
end
