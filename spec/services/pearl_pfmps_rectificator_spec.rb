# frozen_string_literal: true

require "rails_helper"

RSpec.describe PearlPfmpsRectificator do
  subject(:rectificator) { described_class.new(schooling_ids, dry_run: dry_run) }

  let(:dry_run) { false }

  let(:schooling_ids) { [schooling.id] }

  describe "#call" do
    context "when total paid amount exceeds yearly cap just a bit" do
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )

        allow_any_instance_of(Wage).to receive(:yearly_cap).and_return(300) # rubocop:disable RSpec/AnyInstance

        3.times do |i|
          payment_request = create(:asp_payment_request, :paid)
          pfmp = payment_request.pfmp
          pfmp.skip_amounts_yearly_cap_validation = true
          pfmp.update!(
            schooling: schooling,
            amount: 100,
            start_date: (i + 1).months.ago,
            end_date: (i + 1).months.ago + 2.weeks,
            day_count: 10
          )
          payment_request.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "110" } }
          )
        end
      end

      it "processes the schooling when below threshold excess exist but doesnt rectify" do
        results = rectificator.call

        expect(schooling.pfmps.sum(&:amount)).to eq(330)
        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to be_empty
        expect(results[:errors]).to be_empty
      end
    end

    context "when no excess amount exists" do
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )

        allow_any_instance_of(Wage).to receive(:yearly_cap).and_return(100) # rubocop:disable RSpec/AnyInstance

        payment_request = create(:asp_payment_request, :paid)
        pfmp = payment_request.pfmp
        pfmp.skip_amounts_yearly_cap_validation = true
        pfmp.update!(schooling: schooling, amount: 100, day_count: 10)
        payment_request.last_transition.update!(
          metadata: { "PAIEMENT" => { "MTNET" => "100" } }
        )
      end

      it "skips the schooling" do
        results = rectificator.call

        expect(results[:processed]).to eq(1)
        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "no excess amount to rectify")
        )
      end
    end

    context "when schooling already has rectified PFMPs" do
      let(:pfmp) { create(:pfmp, :rectified) }
      let(:schooling) { pfmp.schooling }
      let(:student) { schooling.student }

      it "skips the schooling" do
        results = rectificator.call

        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "already has rectified PFMPs")
        )
      end
    end

    context "when excess amount is exactly at the threshold" do
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }

      around do |example|
        Timecop.safe_mode = false
        Timecop.freeze(Date.parse("#{SchoolYear.current.end_year}-08-01")) do
          example.run
        end
      end

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )

        allow_any_instance_of(Wage).to receive(:yearly_cap).and_return(300) # rubocop:disable RSpec/AnyInstance

        payment_request = create(:asp_payment_request, :paid)
        pfmp = payment_request.pfmp
        pfmp.skip_amounts_yearly_cap_validation = true
        pfmp.update!(
          schooling: schooling,
          amount: 300,
          start_date: 1.month.ago,
          end_date: 1.week.ago,
          day_count: 20
        )
        payment_request.last_transition.update!(
          metadata: { "PAIEMENT" => { "MTNET" => "330" } }
        )
      end

      it "skips the schooling as excess equals threshold" do
        expect(schooling.pfmps.sum(&:paid_amount)).to eq(330)
        expect(schooling.pfmps.first.mef.wage.yearly_cap).to eq(300)

        results = rectificator.call

        expect(results[:processed]).to eq(1)
        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "no excess amount to rectify")
        )
        expect(results[:rectified]).to be_empty
      end
    end

    context "when excess amount is just above threshold with multiple PFMPs" do
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )

        allow_any_instance_of(Wage).to receive(:yearly_cap).and_return(300) # rubocop:disable RSpec/AnyInstance

        2.times do |i|
          payment_request = create(:asp_payment_request, :paid)
          pfmp = payment_request.pfmp
          pfmp.skip_amounts_yearly_cap_validation = true
          pfmp.update!(
            schooling: schooling,
            amount: 150,
            start_date: (i + 1).months.ago,
            end_date: (i + 1).months.ago + 2.weeks,
            day_count: 15
          )
          payment_request.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "170" } }
          )
        end
      end

      it "processes the schooling when above threshold excess exists" do
        expect(schooling.pfmps.sum(&:paid_amount)).to eq(340)
        expect(schooling.pfmps.first.mef.wage.yearly_cap).to eq(300)

        results = rectificator.call

        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to eq([schooling.id])
      end
    end

    context "when 8 PFMPs of 50€ each exceeding 300€ cap" do
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }

      around do |example|
        Timecop.safe_mode = false
        Timecop.freeze(Date.parse("#{SchoolYear.current.end_year}-08-01")) do
          example.run
        end
      end

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )

        allow_any_instance_of(Wage).to receive(:yearly_cap).and_return(300) # rubocop:disable RSpec/AnyInstance

        8.times do |i|
          payment_request = create(:asp_payment_request, :paid)
          pfmp = payment_request.pfmp
          pfmp.skip_amounts_yearly_cap_validation = true
          pfmp.update!(
            schooling: schooling,
            amount: 50,
            start_date: (i + 1).weeks.ago,
            end_date: (i + 1).weeks.ago + 1.week,
            day_count: 5
          )
          payment_request.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "50" } }
          )
        end
      end

      it "reduces PFMPs from 400€ to 300€ total setting 2 pfmps to 0" do
        expect(schooling.pfmps.sum(&:paid_amount)).to eq(400)

        results = rectificator.call

        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to include(schooling.id)

        final_amounts = schooling.pfmps.reload.pluck(:amount)
        expect(final_amounts.sum).to eq(300)
        expect(final_amounts.count(0)).to eq(2)
        expect(final_amounts.count(50)).to eq(6)
      end
    end

    context "when running in dry run mode" do
      let(:dry_run) { true }
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )

        allow_any_instance_of(Wage).to receive(:yearly_cap).and_return(300) # rubocop:disable RSpec/AnyInstance

        8.times do
          payment_request = create(:asp_payment_request, :paid)
          pfmp = payment_request.pfmp
          pfmp.skip_amounts_yearly_cap_validation = true
          pfmp.update!(schooling: schooling, amount: 75, day_count: 15)
          payment_request.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "80" } }
          )
        end
      end

      it "simulates rectification without making actual changes" do
        original_amounts = schooling.pfmps.pluck(:amount)

        results = rectificator.call

        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to include(schooling.id)
        expect(schooling.pfmps.reload.pluck(:amount)).to eq(original_amounts)
      end

      it "does not call rectify_and_update_attributes!" do
        expect_any_instance_of(PfmpManager).not_to receive(:rectify_and_update_attributes!) # rubocop:disable RSpec/AnyInstance

        rectificator.call
      end

      it "still calls sync student data job" do
        expect_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        rectificator.call
      end
    end
  end
end
