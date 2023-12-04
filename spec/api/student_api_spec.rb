# frozen_string_literal: true

require "rails_helper"

describe StudentApi do
  context "when asked for a FIM establishment" do
    let(:etab) { create(:establishment, :sygne_provider) }

    it "uses an instance of the SYGNE API" do
      expect(described_class.api_for(etab)).to be_a StudentApi::Sygne
    end
  end

  context "when asked for a MASA establishment" do
    let(:etab) { create(:establishment, :fregata_provider) }

    it "uses an instance of the Fregata API" do
      expect(described_class.api_for(etab)).to be_a StudentApi::Fregata
    end
  end

  context "when asked for an unknown provider" do
    let(:etab) { create(:establishment, students_provider: nil) }

    it "raises an error" do
      expect { described_class.fetch_students!(etab) }.to raise_error(/no matching API/)
    end
  end
end
