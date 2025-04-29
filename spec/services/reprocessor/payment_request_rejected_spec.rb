# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reprocessor::PaymentRequestRejected do
  describe "#reprocess!" do
    let(:payments_requests) { create_list(:asp_payment_request, 3, :unpaid, reason: "RJT") }
    let(:pfmp_ids) { [] }
    let(:reprocessor) { described_class.new }

    before do
      payments_requests.each do |p_r|
        pfmp_ids << p_r.pfmp.id
      end
    end

    it "reprocesses rejected payment requests" do
      results = reprocessor.reprocess_ids!(pfmp_ids)

      expect(results[:success] + results[:failure]).to eq(3)
    end
  end
end
