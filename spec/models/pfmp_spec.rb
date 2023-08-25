# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pfmp do
  subject(:pfmp) do
    create(:pfmp, student: student).tap { |p| p.payments.destroy_all }
  end

  let(:mef) { create(:mef) }
  let(:student) do
    create(:student).tap { |student| student.classe.update!(mef: mef) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:student) }
    it { is_expected.to have_many(:payments) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:day_count).only_integer.is_greater_than(0) }
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
        pfmp.update!(day_count: 10)

        expect(pfmp).to be_in_state :completed
      end
    end

    context "when no day count is set" do
      it "cannot move to completed" do
        expect { pfmp.transition_to!(:completed) }.to raise_error Statesman::GuardFailedError
      end
    end
  end

  describe "payments" do
    context "when there are previous payments" do
      let!(:old) { create(:payment, pfmp:, updated_at: Date.yesterday) }
      let!(:future) { create(:payment, pfmp:, updated_at: Date.tomorrow) }
      let!(:new) { create(:payment, pfmp:, updated_at: Time.zone.now) }

      it "knows the latest payment" do
        expect(pfmp.reload.latest_payment).to eq future
      end

      it "sorts them chronologically" do
        expect(pfmp.reload.payments).to eq [old, new, future]
      end
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
      max = mef.wage.yearly_cap

      previous = create(:pfmp, :validated, student: pfmp.student)
      create(:payment, :successful, amount: max - 10, pfmp: previous)

      expect(pfmp.calculate_amount).to eq(10)
    end

    it "does not take into account the previous, failed payments" do
      create(:payment, :failed, pfmp: pfmp, amount: 1000)

      expect(pfmp.calculate_amount).to eq(mef.wage.daily_rate * pfmp.day_count)
    end

    it "does not take into account the pending payments" do
      skip "unclear what to do if there is some pending allowance"
    end
  end

  describe "setup_payment!" do
    subject(:pfmp) do
      create(:pfmp, :completed, student: student).tap { |p| p.payments.destroy_all }
    end

    context "when there are no payments" do
      it "creates a new payment" do
        expect { pfmp.setup_payment! }.to change(Payment, :count).by(1)
      end
    end

    context "when the student has already reached the yearly cap" do
      before do
        create(:pfmp, :validated, student: pfmp.student, day_count: 200).tap do |p|
          p.latest_payment.transition_to!(:processing)
          p.latest_payment.transition_to!(:success)
        end
      end

      it "does not create a payment" do
        expect { pfmp.setup_payment! }.not_to change(Payment, :count)
      end
    end

    # context "when there is a successful payment" do
    #   before do
    #     create(:payment, :successful, pfmp:)
    #   end
    # end
  end
end
