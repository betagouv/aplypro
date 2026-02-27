# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Omogen::Rnvp do
  include_context "with the initialization of OMOGEN connection"

  let(:student) { create(:student, :with_french_address) }

  describe "#address" do
    let(:address_data) do
      {
        "ligne2" => student.address_line1,
        "ligne3" => student.address_line2,
        "codePostal" => student.address_postal_code,
        "codeInsee" => student.address_city_insee_code,
        "localite" => student.address_city
      }
    end

    before do
      stub_request(:post, "#{ENV.fetch('RNVP_RESSOURCE_BASE_URL')}/address")
        .to_return(status: 200, body: address_data.to_json)
    end

    context "when the student does not live in France" do
      let(:student) { create(:student, :with_foreign_address) }

      it { expect(described_class.new.address(student)).to be_nil }
    end

    context "when the student lives in France" do
      let(:student) { create(:student, :with_french_address) }

      it { expect(described_class.new.address(student)).to eq(address_data) }
    end
  end

  describe "#connection" do
    it "creates a connection with correct resource URL" do
      expect(described_class.new.resource_connection.url_prefix.to_s).to eq(ENV.fetch("RNVP_RESSOURCE_BASE_URL"))
    end
  end
end
