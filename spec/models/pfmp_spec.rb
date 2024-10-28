# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pfmp do
  subject(:pfmp) { create(:pfmp, schooling: schooling) }

  let(:schooling) do
    mef = create(:mef)
    classe = create(:classe, mef: mef)
    student = create(:student, :with_all_asp_info)
    create(:schooling, student: student, classe: classe)
  end

  describe "associations" do
    it { is_expected.to belong_to(:schooling) }
    it { is_expected.to have_one(:establishment) }
    it { is_expected.to have_one(:classe) }
    it { is_expected.to have_many(:payment_requests) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    it {
      expect(pfmp).to validate_inclusion_of(:start_date)
        .in_range(pfmp.establishment.school_year_range)
        .with_low_message(/ne peut pas précéder/)
        .allow_blank
    }

    it {
      expect(pfmp).to validate_inclusion_of(:end_date)
        .in_range(pfmp.establishment.school_year_range)
        .with_high_message(/ne peut pas excéder/)
        .allow_blank
    }

    it "validates numericality of day count" do
      expect(pfmp).to validate_numericality_of(:day_count)
        .only_integer.is_greater_than(0)
    end

    context "when the end date is before the start" do
      before do
        pfmp.start_date = Time.zone.now
        pfmp.end_date = Date.yesterday
      end

      it { is_expected.not_to be_valid }
    end

    describe "day count" do
      subject(:pfmp) do
        create(
          :pfmp,
          start_date: Date.parse("#{SchoolYear.current.start_year}-10-08"),
          end_date: Date.parse("#{SchoolYear.current.start_year}-10-13")
        )
      end

      context "when the number of days doesn't fit in the date range" do
        before { pfmp.day_count = 8 }

        it { is_expected.not_to be_valid }

        it "has the correct error message" do
          pfmp.validate

          expect(pfmp.errors[:day_count]).to include(/n'est pas cohérent/)
        end
      end

      context "when the number fits exactly in the day range" do
        before { pfmp.day_count = 5 }

        it { is_expected.to be_valid }
      end
    end
  end

  describe "deletion" do
    context "when there is an ongoing payment request" do
      let(:pfmp) { create(:asp_payment_request, :sent).pfmp.reload }

      it "cannot be deleted" do
        expect { pfmp.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
      end
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

    describe "completed" do
      let(:pfmp) { create(:pfmp, :can_be_validated) }

      context "when the PFMP is validated" do
        it "creates a new payment request" do
          expect { pfmp.validate! }.to change(pfmp.payment_requests, :count).by(1)
        end
      end
    end

    describe "validated" do
      let(:pfmp) { create(:asp_payment_request, :ready).pfmp }

      it "cannot create a new payment request" do
        expect { pfmp.payment_requests.create! }.to raise_error ActiveRecord::RecordInvalid
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

    context "when the previous pfmps are validated" do
      let(:pfmps) { create_list(:pfmp, 2, :can_be_validated, schooling: schooling) }

      before { pfmps.first.transition_to!(:validated) }

      it "can move to validated" do
        pfmps.last.transition_to!(:validated)
        expect(pfmps.last).to be_in_state(:validated)
      end
    end

    context "when previous pfmps are not all validated" do
      let(:pfmps) { create_list(:pfmp, 3, :can_be_validated, schooling: schooling) }

      before { pfmps.first.transition_to!(:validated) }

      it "cannot move to validated" do
        expect { pfmps.last.transition_to!(:validated) }.to raise_error Statesman::GuardFailedError
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

  describe "latest_payment_request" do
    it "always picks the latest one" do
      requests = [4, 15, 1].map { |n| create(:asp_payment_request, pfmp: pfmp, created_at: n.days.ago) }

      expect(pfmp.reload.latest_payment_request).to eq requests.last
    end
  end

  describe "can_retrigger_payment?" do
    let(:pfmp) { create(:pfmp, :validated).reload }

    before do
      allow(pfmp.latest_payment_request).to receive(:failed?).and_return :result
    end

    it "delegates to the latest payment request" do
      expect(pfmp.can_retrigger_payment?).to eq :result
    end
  end

  describe "within_schooling_dates?" do
    context "when schooling is open" do
      it "returns true" do
        expect(pfmp.within_schooling_dates?).to be true
      end

      context "when the start date of the pfmp is inferior to start_date of schooling" do
        before do
          pfmp.schooling.update!(start_date: "#{SchoolYear.current.start_year}-10-10")
          pfmp.update!(start_date: pfmp.schooling.start_date - 1.day, end_date: pfmp.schooling.start_date + 30.days)
        end

        it "returns false" do
          expect(pfmp.within_schooling_dates?).to be false
        end
      end
    end

    context "when schooling is closed" do
      before do
        pfmp.schooling.update!(end_date: "#{SchoolYear.current.start_year}-09-29")
      end

      it "returns true" do
        expect(pfmp.within_schooling_dates?).to be true
      end

      context "when the dates of the schooling dont cover the pfmp" do
        before do
          pfmp.schooling.update!(
            start_date: "#{SchoolYear.current.start_year + 1}-03-01",
            end_date: "#{SchoolYear.current.start_year + 1}-04-01"
          )
          pfmp.update!(start_date: pfmp.schooling.start_date - 1.day, end_date: pfmp.schooling.start_date + 30.days)
        end

        it "returns false" do
          expect(pfmp.within_schooling_dates?).to be false
        end
      end
    end
  end

  describe "after_create callback" do
    it "correctly sets the administrative_number" do
      p = create(:pfmp)
      expect(p.administrative_number).to eq("ENPU#{SchoolYear.current.start_year}001")
    end
  end

  describe "#can_be_rebalanced?" do
    context "when the latest payment request is not ongoing and not paid" do
      let(:pfmp) { create(:asp_payment_request, :pending).pfmp }

      it "returns true" do
        expect(pfmp.can_be_rebalanced?).to be true
      end
    end

    context "when the latest payment request is ongoing" do
      let(:pfmp) { create(:asp_payment_request, :sent).pfmp }

      it "returns false" do
        expect(pfmp.can_be_rebalanced?).to be false
      end
    end

    context "when the latest payment request is paid" do
      let(:pfmp) { create(:asp_payment_request, :paid).pfmp }

      it "returns false" do
        expect(pfmp.can_be_rebalanced?).to be false
      end
    end
  end
end
