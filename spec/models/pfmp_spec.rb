# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pfmp do
  subject(:pfmp) { create(:pfmp, schooling: schooling) }

  let(:mef) { create(:mef) }
  let(:classe) { create(:classe, mef: mef) }
  let(:student) { create(:student, :with_all_asp_info) }
  let(:schooling) { create(:schooling, student: student) }

  describe "associations" do
    it { is_expected.to belong_to(:schooling) }
    it { is_expected.to have_many(:payment_requests) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:day_count).only_integer.is_greater_than(0) }

    context "when the end date is before the start" do
      before do
        pfmp.start_date = Time.zone.now
        pfmp.end_date = Date.yesterday
      end

      it { is_expected.not_to be_valid }
    end
  end

  describe "states" do
    it "is initially pending" do
      expect(pfmp).to be_in_state :pending
    end

    it "cannot move to validating straight away" do
      expect { pfmp.transition_to!(:validated) }.to raise_error Statesman::TransitionFailedError
    end

    context "when created with a day count" do
      it "moves directly to completed" do
        expect(create(:pfmp, day_count: 10)).to be_in_state :completed
      end
    end

    context "when a day count is set" do
      it "is moved to completed" do
        expect { pfmp.update!(day_count: 10) }
          .to change(pfmp, :current_state)
          .from("pending")
          .to("completed")
      end
    end

    context "when a day count is unset" do
      subject(:pfmp) { create(:pfmp, :completed) }

      it "moves back to pending" do
        expect { pfmp.update!(day_count: nil) }
          .to change(pfmp, :current_state)
          .from("completed")
          .to("pending")
      end
    end

    context "when no day count is set" do
      it "cannot move to completed" do
        expect { pfmp.transition_to!(:completed) }.to raise_error Statesman::GuardFailedError
      end
    end
  end

  describe "calculate_amount" do
    let(:amount) { mef.wage.daily_rate * pfmp.day_count }

    before { pfmp.update!(day_count: 10) }

    context "when the amount is over the allowance left" do
      before do
        allow(pfmp.student).to receive(:allowance_left).and_return(amount - 1)
      end

      it "returns the allowance left" do
        expect(pfmp.calculate_amount).to eq amount - 1
      end
    end

    context "when the amount is under the allowance left" do
      before do
        allow(pfmp.student).to receive(:allowance_left).and_return(amount + 1)
      end

      it "returns the amount" do
        expect(pfmp.calculate_amount).to eq amount
      end
    end

    context "when the amount is updated" do
      it "updates the amount" do
        expect { pfmp.update!(day_count: 20) }.to change(pfmp, :amount).from(amount).to(amount * 2)
      end

      context "with a validated PFMP" do
        before do
          pfmp.validate!
        end

        it "throws an error" do
          expect { pfmp.update!(day_count: 15) }.to raise_error(/day count changed/)
        end
      end
    end
  end

  describe "setup_payment!" do
    subject(:pfmp) { create(:pfmp, schooling: schooling, day_count: 10) }

    it "creates a new payment" do
      expect { pfmp.setup_payment! }.to change(ASP::PaymentRequest, :count).by(1)
    end

    context "when there is no allowance left" do
      before do
        create(:pfmp, :validated, schooling: schooling, day_count: 100)
      end

      it "does not create a payment" do
        expect { pfmp.setup_payment! }.not_to change(ASP::PaymentRequest, :count)
      end
    end
  end

  describe "relative_index" do
    subject(:index) { pfmp.relative_index }

    it { is_expected.to eq 0 }

    context "when there are multiple PFMPs" do
      before do
        create(:pfmp, schooling: schooling, created_at: Date.yesterday)
        create(:pfmp, schooling: schooling, created_at: Date.yesterday)
        create(:pfmp, schooling: schooling, created_at: Date.tomorrow)
      end

      it "accounts for them" do
        expect(index).to eq 2
      end
    end
  end
end
