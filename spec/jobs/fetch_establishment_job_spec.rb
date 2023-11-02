# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchEstablishmentJob do
  let(:etab) { create(:establishment, :with_fim_user) }
  let!(:fixture) { Rails.root.join("mock/data/etab.json").read }

  before do
    allow(EstablishmentApi).to receive(:fetch!).and_call_original

    stub_request(:get, /#{ENV.fetch('APLYPRO_ESTABLISHMENTS_DATA_URL')}/)
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/json"
        }
      )
      .to_return(status: 200, body: fixture, headers: { "Content-Type" => "application/json" })
  end

  it "calls the EstablishmentApi proxy" do
    described_class.perform_now(etab)

    expect(EstablishmentApi).to have_received(:fetch!).with(etab.uai)
  end

  it "updates the establishement's name" do
    expect { described_class.perform_now(etab) }.to change { etab.reload.name }.to "Lycée de la Mer Paul Bousquet"
  end

  Establishment::API_MAPPING.each_value do |attr|
    it "updates the `#{attr}' attribute" do
      expect { described_class.perform_now(etab) }.to change(etab, attr)
    end
  end
end
