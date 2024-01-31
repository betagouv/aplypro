# frozen_string_literal: true

require "rails_helper"
require "./script/payments_fixer"

RSpec.describe PaymentsFixer do
  subject(:fix) { described_class.fix_all! }

  before do
    create_list(:pfmp, 2, :validated)
  end

  it "goes well" do
    expect { fix }.not_to raise_error
  end

  context "when there is an exta payment for a pfmp" do
    before do
      create(:payment, pfmp: Pfmp.last)
    end

    it "deletes the extra payments" do
      expect { fix }.to change(Payment, :count).by(-1)
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
    let(:mef) { create(:mef) }
    let(:classes) { create_list(:classe, 3, mef: mef) }

    # we need to close the schoolings one by one to have them valid
    let(:schoolings) do
      classes.map.with_index do |classe, index|
        schooling = create(:schooling, student: student, classe: classe)
        schooling.update(end_date: Time.zone.today - index.days) if index < 2
        schooling
      end
    end

    let(:pfmps) do
      schoolings.map do |schooling|
        create(:pfmp, :validated, schooling: schooling, day_count: day_count)
      end
    end

    let(:payments) { pfmps.map(&:latest_payment) }

    before do
      payments.each { |payment| payment.update(amount: 27) }
    end

    it "corrects all the payments amounts" do
      expect { fix }.to change { payments.map { |payment| payment.reload.amount } }.to [4, 4, 4]
    end

    context "when the sum of payments goes over the yearly cap" do
      let(:day_count) { 40 }

      it "corrects all the payments amounts, limited by the yearly cap" do
        expect { fix }.to change { payments.map { |payment| payment.reload.amount } }.to [40, 40, 20]
      end
    end

    context "when the sum of payments goes way over the yearly cap" do
      let(:day_count) { 70 }

      it "corrects all the payments amounts, and deletes the payments over the cap" do
        expect { fix }.to change { pfmps.map(&:reload).map(&:latest_payment).compact.map(&:amount) }.to [70, 30]
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
