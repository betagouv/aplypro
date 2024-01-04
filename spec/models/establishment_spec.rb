# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:establishment) { build(:establishment, :sygne_provider) }

  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }

  describe "some_attributive_decisions?" do
    subject { establishment.some_attributive_decisions? }

    context "when there are some attributive decisions" do
      before { create(:schooling, :with_attributive_decision, establishment: establishment) }

      it { is_expected.to be_truthy }
    end

    context "when there are no attributive decisions" do
      before { create(:schooling, establishment: establishment) }

      it { is_expected.to be_falsey }
    end
  end

  describe "some_attributive_decisions_generating?" do
    context "when a schooling is marked for generation" do
      let(:schooling) { create(:schooling, establishment: establishment) }

      it "returns true" do
        expect { schooling.update!(generating_attributive_decision: true) }
          .to change(establishment, :some_attributive_decisions_generating?)
          .from(false).to(true)
      end
    end
  end

  describe "confirmed_director" do
    subject { establishment.confirmed_director }

    context "when there is an existing confirmed director" do
      let!(:confirmed_director) { create(:user, :confirmed_director, establishment: establishment) }

      it { is_expected.to eq confirmed_director }
    end

    context "when there isn't any existing confirmed director" do
      it { is_expected.to be_nil }
    end
  end
end
