# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reprocessor::PaymentRequestIncomplete do
  let(:reason_key) { "ine_not_found" }
  let(:validation_message) do
    I18n.t(
      "activerecord.errors.models.asp/payment_request.attributes.ready_state_validation.#{reason_key}"
    )
  end

  describe "#reprocess!" do
    let(:reprocessor) { described_class.new }

    before do
      create_list(:asp_payment_request, 3, :incomplete, incomplete_reason: :ine_not_found)
    end

    it "reprocesses incomplete payment requests" do
      results = reprocessor.reprocess_all!(reason_key)

      expect(results[:success] + results[:failure]).to eq(3)
    end
  end
end
