# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Omogen::Rnvp do
  include_context "with the initialization of OMOGEN connection"

  let(:student) { create(:student, :with_french_address) }
  let(:address_data) do
    {
      "id" => student.id,
      "ligne2" => student.address_line1,
      "ligne3" => student.address_line2,
      "codePostal" => student.address_postal_code,
      "codeInsee" => student.address_city_insee_code,
      "localite" => student.address_city
    }
  end

  describe "#address" do
    context "when the student does not live in France" do
      let(:student) { create(:student, :with_foreign_address) }

      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/address")
          .to_return(status: 200, body: address_data.to_json)
      end

      it { expect(described_class.new.address(student)).to be_nil }
    end

    context "when the student lives in France" do
      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/address")
          .to_return(status: 200, body: address_data.to_json)
      end

      it { expect(described_class.new.address(student)).to eq(address_data) }
    end

    context "when there is an error" do
      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/address")
          .to_return(status: 500, body: "Une erreur technique non prévisible est survenue.")
      end

      it { expect(described_class.new.address(student)).to be_nil }
    end
  end

  describe "#addresses" do
    let(:student2) { create(:student, :with_french_address) }
    let(:address_data2) do
      {
        "id" => student2.id,
        "ligne2" => student2.address_line1,
        "ligne3" => student2.address_line2,
        "codePostal" => student2.address_postal_code,
        "codeInsee" => student2.address_city_insee_code,
        "localite" => student2.address_city
      }
    end

    context "when students live in France" do
      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .to_return(status: 200, body: { data: { rnvpAddresses: [address_data, address_data2] } }.to_json)
      end

      it { expect(described_class.new.addresses([student, student2])).to eq([address_data, address_data2]) }
    end

    context "when a student does not live in France" do
      let(:student2) { create(:student, :with_foreign_address) }

      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .to_return(status: 200, body: { data: { rnvpAddresses: [address_data] } }.to_json)
      end

      it { expect(described_class.new.addresses([student, student2])).to eq([address_data]) }
    end

    context "when there are more students than the limit" do
      before do
        stub_const("Omogen::Rnvp::ADDRESSES_LIMIT", 1)

        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .with(body: { addresses: [address_data] })
          .to_return(status: 200, body: { data: { rnvpAddresses: [address_data] } }.to_json)

        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .with(body: { addresses: [address_data2] })
          .to_return(status: 200, body: { data: { rnvpAddresses: [address_data2] } }.to_json)
      end

      it { expect(described_class.new.addresses([student, student2])).to eq([address_data, address_data2]) }
    end

    context "when API returns a waiting timer" do
      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .with { |req| req.headers["Job-Uuid"].nil? }
          .to_return(status: 200, body: { ticket: { estimatedWaitingTimeSeconds: "1", jobUUID: "123456" } }.to_json)

        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .with { |req| req.headers["Job-Uuid"] = "123456" }
          .to_return(status: 200, body: { data: { rnvpAddresses: [address_data] } }.to_json)
      end

      it { expect(described_class.new.addresses([student])).to eq([address_data]) }
    end

    context "when the API does not return something on time" do
      before do
        stub_const("Omogen::Rnvp::TIMEOUT_LIMIT", 2)

        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .to_return(status: 200, body: { ticket: { estimatedWaitingTimeSeconds: "1", jobUUID: "123456" } }.to_json)
      end

      it { expect(described_class.new.addresses([student])).to eq([]) }
    end

    context "when there is an error" do
      before do
        stub_request(:post, "#{ENV.fetch('RNVP_RESOURCE_BASE_URL')}/batch")
          .to_return(status: 500, body: "Une erreur technique non prévisible est survenue.")
      end

      it { expect(described_class.new.addresses([student, student2])).to eq([]) }
    end
  end

  describe "#connection" do
    it "creates a connection with correct resource URL" do
      expect(described_class.new.resource_connection.url_prefix.to_s).to eq(ENV.fetch("RNVP_RESOURCE_BASE_URL"))
    end
  end
end
