# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::Adresse::FranceMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }
  let(:student) { payment_request.student }

  describe "codeinseepays" do
    subject(:code) { mapper.codeinseepays }

    before do
      allow(InseeCountryCodeMapper).to receive(:call).and_return :value
    end

    it "delegates to the INSEE country code mapper" do
      expect(code).to eq :value
    end
  end

  describe "codecominsee" do
    subject(:code) { mapper.codecominsee }

    before do
      allow(InseeExceptionCodes).to receive(:transform_insee_code).and_return :value
    end

    it "delegates to the INSEE exception codes transformer" do
      expect(code).to eq :value
    end
  end
end
