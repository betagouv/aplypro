# frozen_string_literal: true

require "rails_helper"

RSpec.describe PearlPfmpsRectificator do
  subject(:rectificator) { described_class.new(schooling_ids) }

  let(:schooling_ids) { [schooling.id] }

  describe "#call" do
    context "when total paid amount exceeds yearly cap" do
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

        allow_any_instance_of(PfmpManager).to receive(:rectify_and_update_attributes!).and_return(true) # rubocop:disable RSpec/AnyInstance
      end

      it "rectifies the schooling" do
        results = rectificator.call
        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to include(schooling.id)
        expect(schooling.pfmps.pluck(:amount)).to eq([0, 0, 0, 0, 80, 80, 80, 80])
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

    context "when excess amount is exactly at the 30€ threshold" do
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

        4.times do |i|
          payment_request = create(:asp_payment_request, :paid)
          pfmp = payment_request.pfmp
          pfmp.skip_amounts_yearly_cap_validation = true
          pfmp.update!(
            schooling: schooling,
            amount: 80,
            start_date: (i + 1).months.ago,
            end_date: (i + 1).months.ago + 2.weeks,
            day_count: 10
          )
          payment_request.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "85" } }
          )
        end

        allow_any_instance_of(PfmpManager).to receive(:rectify_and_update_attributes!) # rubocop:disable RSpec/AnyInstance
      end

      it "distributes excess reduction across PFMPs respecting 30€ threshold" do
        expect(schooling.pfmps.sum(&:paid_amount)).to eq(340)
        expect(schooling.pfmps.first.mef.wage.yearly_cap).to eq(300)

        results = rectificator.call

        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to include(schooling.id)

        updated_amounts = schooling.pfmps.reload.pluck(:amount).sort
        expect(updated_amounts).to eq([45, 85, 85, 85])
      end
    end
  end
end
