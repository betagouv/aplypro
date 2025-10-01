# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sync::EstablishmentJob do
  # we want a "dehydrated" (i.e not API-refreshed) establishment to
  # avoid flaky specs where the data returned from the fixture matches
  # the factory's attribute which will crash the
  #
  # expect(api call).to change (establishment, attribute)
  #
  # matcher further below.
  let(:establishment) { create(:establishment, :dehydrated, :sygne_provider) }
  let(:json) { Rails.root.join("mock/data/etab.json").read }

  before do
    allow(DataEducationApi::EstablishmentApi).to receive(:fetch!).and_return(JSON.parse(json))
  end

  it "calls the EstablishmentApi proxy" do
    described_class.perform_now(establishment)

    expect(DataEducationApi::EstablishmentApi).to have_received(:fetch!).with(establishment.uai)
  end

  Establishment::API_MAPPING.each_value do |attr|
    it "updates the `#{attr}' attribute" do
      expect { described_class.perform_now(establishment) }.to change(establishment, attr)
    end
  end
end
