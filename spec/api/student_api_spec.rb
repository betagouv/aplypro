# frozen_string_literal: true

require "rails_helper"

describe StudentApi do
  context "when asked for a FIM establishment" do
    let(:etab) { create(:establishment, :with_fim_principal) }
    let(:sygne) { instance_double(StudentApi::Sygne) }

    before do
      allow(StudentApi::Sygne).to receive(:new).and_return sygne

      allow(sygne).to receive(:fetch_and_parse!)
    end

    it "uses an instance of the SYGNE API" do
      described_class.fetch_students!(etab)

      expect(sygne).to have_received(:fetch_and_parse!).with(no_args)
    end
  end

  context "when asked for an unknown provider" do
    let(:etab) { create(:establishment) }

    it "raises an error" do
      expect { described_class.fetch_students!(etab) }.to raise_error(/no matching API/)
    end
  end
end
