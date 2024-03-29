# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentFixer, skip: "these tests are slow and we're not going to use the PaymentFixer for a while" do
  subject(:fix) { described_class.call }

  let(:day_count) { 3 }
  let(:amount) { 3 }
  let(:pfmp) { create(:pfmp, :completed, day_count: day_count) }

  before do
    pfmp.mef.wage.update!(daily_rate: 1, yearly_cap: 10)

    # skip validation to avoid the callbacks (which trigger the calculate_amount hook)
    pfmp.update_columns(amount: amount) # rubocop:disable Rails/SkipsModelValidations
  end

  context "when the PFMP amount is wrong" do
    let(:amount) { 10 }

    it "corrects the payment amount" do
      expect { fix }.to change { pfmp.reload.amount }.to 3
    end
  end

  context "when it goes over the yearly cap" do
    let(:day_count) { 1000 }
    let(:amount) { 15 }

    it "corrects the payment amount, limited by the yearly cap" do
      expect { fix }.to change { pfmp.reload.amount }.to 10
    end
  end

  context "when a student has multiple PFMPs for the same diploma" do
    let(:previous) { create(:pfmp, schooling: pfmp.schooling, created_at: Date.yesterday) }

    context "without a day count" do
      it "does not take it into account" do
        expect { fix }.not_to change(pfmp, :amount)
      end
    end

    context "with a day count" do
      before { previous.update!(day_count: 9) }

      it "accounts for it" do
        expect { fix }.to change { pfmp.reload.amount }.from(amount).to(1)
      end

      context "when the PFMP happened later" do
        before { previous.update!(created_at: Date.tomorrow) }

        it "accounts for it" do
          expect { fix }.not_to(change { pfmp.reload.amount })
        end
      end
    end
  end

  context "when a student has multiple PFMPs from other diplomas" do
    before do
      create_list(:schooling, 2, :closed, student: pfmp.schooling.student).map do |schooling|
        create(:pfmp, :completed, day_count: 100, schooling: schooling)
      end
    end

    it "does not account for them" do
      expect { fix }.not_to(change { pfmp.reload.amount })
    end
  end

  context "when the previous PFMPs go over the yearly cap" do
    before do
      create_list(:pfmp, 2, schooling: pfmp.schooling, day_count: 5, created_at: Date.yesterday)
    end

    it "sets the amount to 0" do
      expect { fix }.to change { pfmp.reload.amount }.from(3).to(0)
    end
  end
end
