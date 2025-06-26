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
        student.update!(
          address_line1: "123 Main St",
          address_country_code: "99100",
          address_postal_code: "75001",
          address_city_insee_code: "75101"
        )
      end

      it "rectifies the PFMP" do
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
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }
      let!(:pfmp) { create(:pfmp, :validated, schooling: schooling, amount: 100, day_count: 10) }
      let!(:payment_request) do
        create(:asp_payment_request, :paid, pfmp: pfmp).tap do |pr|
          pr.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "120" } }
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

      it "skips the schooling with appropriate reason" do
        corrector = described_class.new([schooling.id])
        results = corrector.call

        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "amount too small or zero")
        )
        expect(results[:rectified]).to be_empty
      end
    end

    context "when rectification amount is zero" do
      let(:schooling) { create(:schooling) }
      let(:student) { schooling.student }
      let!(:pfmp) { create(:pfmp, :validated, schooling: schooling, amount: 150, day_count: 15) }
      let!(:payment_request) do
        create(:asp_payment_request, :paid, pfmp: pfmp).tap do |pr|
          pr.last_transition.update!(
            metadata: { "PAIEMENT" => { "MTNET" => "150" } }
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

      it "skips the schooling with appropriate reason" do
        corrector = described_class.new([schooling.id])
        results = corrector.call

        expect(results[:skipped]).to include(
          hash_including(id: schooling.id, reason: "amount too small or zero")
        )
        expect(results[:rectified]).to be_empty
      end
    end
  end
end
