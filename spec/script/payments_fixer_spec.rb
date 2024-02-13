# frozen_string_literal: true

require "rails_helper"
require "./script/payments_fixer"

RSpec.describe PaymentsFixer do
  subject(:fix) { described_class.fix_all! }

  context "when there is an exta payment for a pfmp" do
    let(:pfmps) { create_list(:pfmp, 2, :validated) }
    let!(:extra_payment) { create(:payment, pfmp: pfmps.last) }

    it "deletes the extra payment" do
      fix
      expect { extra_payment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when there is a payment with incorrect amount" do
    let(:day_count) { 4 }
    let(:pfmp) { create(:pfmp, :validated, day_count: day_count) }
    let(:payment) { pfmp.payments.first }

    before do
      payment.update(amount: 27)
    end

    it "corrects the payment amount" do
      expect { fix }.to change { payment.reload.amount }.to 4
    end

    context "when it goes over the yearly cap" do
      let(:day_count) { 400 }

      it "corrects the payment amount, limited by the yearly cap" do
        expect { fix }.to change { payment.reload.amount }.to 100
      end
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  context "when there is several pfmps for the same student and same mef" do
    let(:day_count) { 4 }
    let(:student) { create(:student) }
    let(:mef) { create(:mef, daily_rate: 1, yearly_cap: 100) }
    let(:classes) { create_list(:classe, 3, mef: mef) }

    # we need to close the schoolings one by one to have them valid
    let(:schoolings) do
      classes.map.with_index do |classe, index|
        schooling = create(:schooling, student: student, classe: classe)
        schooling.update(end_date: Time.zone.today - index.days) if index < classes.count - 1
        schooling
      end
    end

    let(:pfmps) do
      schoolings.map do |schooling|
        create(:pfmp, schooling: schooling, day_count: day_count)
      end
    end

    let!(:payments) do
      pfmps.map do |pfmp|
        create(:payment, pfmp: pfmp, amount: 27)
      end
    end

    it "corrects all the payments amounts" do
      expect { fix }.to change { payments.map { |payment| payment.reload.amount } }.to [4, 4, 4]
    end

    context "when the yearly_cap is 100€ and there is 3 payments of 40€" do
      let(:day_count) { 40 }

      it "corrects all the payments amounts, limited by the yearly cap" do
        expect { fix }.to change { payments.map { |payment| payment.reload.amount } }.to [40, 40, 20]
      end
    end

    context "when the yearly_cap is 100€ and there is 3 payments of 70€" do
      let(:day_count) { 70 }

      it "corrects all the payments amounts, and deletes the payments over the cap" do
        expect { fix }.to change { pfmps.map(&:reload).map(&:latest_payment).compact.map(&:amount) }.to [70, 30]
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
