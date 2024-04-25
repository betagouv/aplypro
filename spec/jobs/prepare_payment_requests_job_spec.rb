# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreparePaymentRequestsJob do
  include ActiveJob::TestHelper

  describe '#perform' do
    let(:payment_request1) { create(:asp_payment_request, :pending) }
    let(:payment_request2) { create(:asp_payment_request, :sendable_with_issues) }

    before do
      PreparePaymentRequestsJob.perform_now
    end

    it 'transitions each pending payment request to ready' do
      expect(payment_request1.reload.current_state).to eq('ready')
      expect(payment_request2.reload.current_state).to eq('incomplete')
    end
  end
end
