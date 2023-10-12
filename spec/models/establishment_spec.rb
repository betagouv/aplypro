# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:etab) { build(:establishment, :with_fim_user) }

  let!(:fixture) { Rails.root.join("mock/data/etab.json").read }

  before do
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

  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }

  describe "data refresh" do
    context "when it is created" do
      it "calls the queue_refresh method" do
        expect { etab.save }.to have_enqueued_job(FetchEstablishmentJob).with(etab)

        etab.save
      end
    end

    context "when it is updated" do
      before do
        etab.save
      end

      it "does not call the queue_refresh method" do
        expect { etab.update!(name: "New name") }.not_to have_enqueued_job
      end
    end
  end

  describe "fetch_data!" do
    Establishment::API_MAPPING.each_value do |attr|
      it "updates the `#{attr}' attribute" do
        expect { etab.fetch_data! }.to change(etab, attr)
      end
    end
  end
end
