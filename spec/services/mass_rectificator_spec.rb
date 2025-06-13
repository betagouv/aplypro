# frozen_string_literal: true

require "rails_helper"

RSpec.describe MassRectificator do
  subject(:corrector) { described_class.new(schooling_ids) }

  let(:schooling_ids) { [schooling.id] }
  let(:schooling) { pfmp.schooling }
  let(:student) { schooling.student }
  let!(:pfmp) { create(:asp_payment_request, :paid).pfmp }

  describe "#call" do
    context "when processing a valid schooling" do
      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(PfmpManager).to receive(:rectify_and_update_attributes!) # rubocop:disable RSpec/AnyInstance
        student.update!(
          address_line1: "123 Main St",
          address_country_code: "FR",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )
      end

      it "rectifies the PFMP" do # rubocop:disable RSpec/MultipleExpectations
        results = corrector.call

        expect(results[:processed]).to eq(1)
        expect(results[:rectified]).to include(schooling.id)
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

    context "when rectification amount threshold is not reached" do
      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(PfmpManager).to receive(:rectify_and_update_attributes!)
          .and_raise(PfmpManager::RectificationAmountThresholdNotReachedError)
        student.update!(
          address_line1: "123 Main St",
          address_country_code: "FR",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )
      end

      it "skips the schooling with appropriate reason" do
        results = corrector.call

        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "amount too small or zero")
        )
        expect(results[:rectified]).to be_empty
      end
    end

    context "when rectification amount is zero" do
      before do
        allow_any_instance_of(Sync::StudentJob).to receive(:perform) # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(PfmpManager).to receive(:rectify_and_update_attributes!)
          .and_raise(PfmpManager::RectificationAmountZeroError)
        student.update!(
          address_line1: "123 Main St",
          address_country_code: "FR",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )
      end

      it "skips the schooling with appropriate reason" do
        results = corrector.call

        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "amount too small or zero")
        )
        expect(results[:rectified]).to be_empty
      end
    end
  end
end
