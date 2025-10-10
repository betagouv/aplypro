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

  it "calls the EstablishmentApi proxy" do
    described_class.perform_now(establishment)

    expect(establishment.reload.name).not_to be_nil
  end

  Establishment::API_MAPPING.each_value do |attr|
    it "updates the `#{attr}' attribute" do
      expect { described_class.perform_now(establishment) }.to change(establishment, attr)
    end
  end
end
