# frozen_string_literal: true

require "rails_helper"

RSpec.describe MassRectificator do
  subject(:corrector) { described_class.new(schooling_ids, dry_run: dry_run) }

  let(:dry_run) { false }

  let(:schooling_ids) { [schooling.id] }
  let(:schooling) { pfmp.schooling }
  let(:student) { schooling.student }
  let!(:pfmp) { create(:asp_payment_request, :paid).pfmp }

  describe "#call" do
    context "when processing a schooling successfully" do
      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance
        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )
      end

      it "processes the schooling and handles validation appropriately" do
        results = corrector.call

        expect(results[:processed]).to eq(1)
        expect(results[:errors].size + results[:skipped].size + results[:rectified].size).to eq(1)
      end
    end

    context "when schooling already has rectified PFMPs" do
      let!(:pfmp) { create(:pfmp, :rectified) } # rubocop:disable RSpec/LetSetup

      it "skips the schooling" do
        results = corrector.call

        expect(results[:skipped]).to include(hash_including(id: schooling.id, reason: "already has rectified PFMPs"))
      end
    end

    context "when an error occurs during processing" do
      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform).and_raise(StandardError, "Test error") # rubocop:disable RSpec/AnyInstance
      end

      it "handles the error gracefully" do
        results = corrector.call

        expect(results[:errors]).to include(hash_including(id: schooling.id, error: "Test error"))
      end
    end

    context "when processing encounters validation error" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }
      let!(:pfmp) { create(:pfmp, :validated, schooling: schooling, amount: 100, day_count: 10) }
      let!(:payment_request) do # rubocop:disable RSpec/LetSetup
        create(:asp_payment_request, :paid, pfmp: pfmp).tap do |pr|
          pr.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "100" } }
          )
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
      end

      it "handles validation errors gracefully" do
        corrector = described_class.new([schooling.id])
        results = corrector.call

        expect(results[:processed]).to eq(1)
        expect(results[:errors].size + results[:skipped].size + results[:rectified].size).to eq(1)
      end
    end

    context "when running in dry run mode" do
      let(:dry_run) { true }

      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance
        student.update!(
          address_line1: "123 Main St",
          address_country_code: "FR",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )
      end

      it "simulates rectification without making actual changes" do
        results = corrector.call

        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to include(schooling.id)
      end

      it "does not call rectify_and_update_attributes!" do
        expect_any_instance_of(PfmpManager).not_to receive(:rectify_and_update_attributes!) # rubocop:disable RSpec/AnyInstance

        corrector.call
      end

      it "still calls sync student data job" do
        expect_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance

        corrector.call
      end
    end
  end
end
