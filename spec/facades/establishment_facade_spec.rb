# frozen_string_literal: true

require "rails_helper"

RSpec.describe EstablishmentFacade do
  subject(:establishment_facade) { described_class.new(establishment) }

  let(:establishment) { build(:establishment, :sygne_provider) }

  describe "#payment_requests_counts" do
    subject(:payment_requests_counts) { establishment_facade.payment_requests_counts }

    let(:classe) { create(:classe, establishment: establishment) }
    let(:pfmps) { create_list(:pfmp, 10, classe: classe) }

    context "when there are no payment requests" do
      it "counts all statuses at zero" do
        expect(payment_requests_counts.values).to all be_zero
      end
    end

    context "when there are 2 payment requests pending and 3 ready" do
      before do
        pfmps.first(2).each { |pfmp| create(:asp_payment_request, :pending, pfmp: pfmp) }
        pfmps.first(3).each { |pfmp| create(:asp_payment_request, :ready, pfmp: pfmp) }
      end

      it "sums the pending and ready counts in the pending key" do
        expect(payment_requests_counts[:pending]).to eq 5
      end
    end

    context "when there are 4 payment requests sent and 5 integrated" do
      before do
        pfmps.first(4).each { |pfmp| create(:asp_payment_request, :sent, pfmp: pfmp) }
        pfmps.first(5).each { |pfmp| create(:asp_payment_request, :integrated, pfmp: pfmp) }
      end

      it "sums the sent and integrated counts in the sent key" do
        expect(payment_requests_counts[:sent]).to eq 9
      end
    end

    context "when there is 1 payment request in each state" do
      before do
        ASP::PaymentRequestStateMachine.states.each_with_index do |state, index|
          create(:asp_payment_request, state.to_sym, pfmp: pfmps[index])
        end
      end

      it "groups the pending+ready and sent+integrated counts" do
        expect(payment_requests_counts).to eq(
          { pending: 2, incomplete: 1, sent: 2, rejected: 1, paid: 1, unpaid: 1 }
        )
      end
    end
  end
end
