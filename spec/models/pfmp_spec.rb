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
    it { is_expected.to have_many(:payments) }
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

  describe "payments" do
    it "sorts them chronologically" do
      payments = [5, 0, -2]
                 .map { |n| Time.zone.now + n.days }
                 .map { |date| create(:payment, pfmp:, created_at: date) }

      expect(pfmp.reload.payments).to eq payments.reverse
    end
  end

  describe "calculate_amount" do
    before do
      pfmp.day_count = 10
      pfmp.transition_to!(:completed)
    end

    it "is equal to the number of days time the daily rate" do
      expect(pfmp.calculate_amount).to eq(mef.wage.daily_rate * pfmp.day_count)
    end

    it "takes into account the yearly cap" do
      pfmp.day_count = 200

      expect(pfmp.calculate_amount).to eq mef.wage.yearly_cap
    end

    it "takes into account the previous payments" do
      yearly_cap = mef.wage.yearly_cap

      paid = create(:pfmp, :paid, day_count: 3, schooling: pfmp.schooling)
      paid.payments.first.update!(amount: yearly_cap - 10)

      expect(pfmp.calculate_amount).to eq(10)
    end
  end

  describe "setup_payment!" do
    subject(:pfmp) do
      create(:pfmp, :completed, schooling: schooling).tap { |p| p.payments.destroy_all }
    end

    context "when there are no payments" do
      it "creates a new payment" do
        expect { pfmp.setup_payment! }.to change(Payment, :count).by(1)
      end
    end

    context "when the student has already reached the yearly cap" do
      before { create(:pfmp, :paid, schooling: pfmp.schooling, day_count: 1000) }

      it "does not create a payment" do
        expect { pfmp.setup_payment! }.not_to change(Payment, :count)
      end
    end
  end
end
