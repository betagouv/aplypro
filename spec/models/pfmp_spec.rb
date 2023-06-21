# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pfmp do
  subject(:pfmp) { create(:pfmp) }

  describe "associations" do
    it { is_expected.to belong_to(:student) }
    it { is_expected.to have_many(:payments) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
  end

  describe "payments" do
    context "when the PFMP is new" do
      it "has no payments" do
        expect(pfmp.payments).to be_empty
      end
    end

    context "when there are many payments" do
      let!(:old) { create(:payment, pfmp:, updated_at: Date.yesterday) }
      let!(:future) { create(:payment, pfmp:, updated_at: Date.tomorrow) }
      let!(:new) { create(:payment, pfmp:, updated_at: Time.zone.now) }

      it "knows the latest payment" do
        expect(pfmp.latest_payment).to eq future
      end

      it "sorts them chronologically" do
        expect(pfmp.payments).to eq [old, new, future]
      end
    end

    describe "setup_payment!" do
      context "when there are no payments" do
        it "creates a new payment" do
          expect { pfmp.setup_payment! }.to change(Payment, :count).by(1)
        end
      end

      # context "when there is a successful payment" do
      #   before do
      #     create(:payment, :successful, pfmp:)
      #   end
      # end
    end
  end
end
