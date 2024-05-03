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
    let!(:user) { create(:user, :confirmed_director, establishment: establishment) }

    it { is_expected.to be_valid }

    context "when the confirmed_director is not a director" do
      before { user.establishment_user_roles.first.update(role: :authorised) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "excluded?" do
    before do
      allow(Exclusion).to receive(:establishment_excluded?).and_return "a fake result"
    end

    it "forwards its UAI" do
      establishment.excluded?

      expect(Exclusion).to have_received(:establishment_excluded?).with(establishment.uai)
    end

    it "returns the result" do
      expect(establishment.excluded?).to eq "a fake result"
    end
  end
end
