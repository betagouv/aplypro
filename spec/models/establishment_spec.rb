# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:etab) { build(:establishment, :with_fim_principal) }

  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }
  it { is_expected.to have_one(:principal) }

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
end
