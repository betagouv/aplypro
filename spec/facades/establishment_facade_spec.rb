# frozen_string_literal: true

require "rails_helper"

RSpec.describe EstablishmentFacade do
  subject(:establishment_facade) { described_class.new(establishment, school_year) }

  let(:establishment) { build(:establishment, :sygne_provider) }
  let(:school_year) { create(:school_year, start_year: 2020) }
  let(:classe) { build(:classe, establishment: establishment, school_year: school_year) }

  before do
    payment_requests.each do |pr|
      pr.schooling.update!(classe: classe)
    end
  end

  describe "#payment_requests_counts" do
    subject(:payment_requests_counts) { establishment_facade.payment_requests_counts }

    context "when there are no payment requests" do
      let(:payment_requests) { [] }

      it "counts all statuses at zero" do
        expect(payment_requests_counts.values).to all be_zero
      end
    end

    context "when there are payment requests from another year" do
      subject(:establishment_facade) { described_class.new(establishment, new_school_year) }

      let(:payment_requests) { create_list(:asp_payment_request, 2, :pending) }
      let(:new_school_year) { create(:school_year, start_year: 2021) }

      it "doesn't account for them" do
        expect(payment_requests_counts[:pending]).to eq 0
      end
    end

    context "when there are 2 payment requests pending and 3 ready" do
      let(:payment_requests) do
        [
          create_list(:asp_payment_request, 2, :pending),
          create_list(:asp_payment_request, 3, :ready)
        ].flatten
      end

      it "sums the pending and ready counts in the pending key" do
        expect(payment_requests_counts[:pending]).to eq 5
      end
    end

    context "when there are 4 payment requests sent and 5 integrated" do
      let(:payment_requests) do
        [
          create_list(:asp_payment_request, 4, :sent),
          create_list(:asp_payment_request, 5, :integrated)
        ].flatten
      end

      it "sums the sent and integrated counts in the sent key" do
        expect(payment_requests_counts[:sent]).to eq 9
      end
    end

    context "when there is 1 payment request in each state" do
      let(:payment_requests) do
        ASP::PaymentRequestStateMachine.states.map do |state|
          create(:asp_payment_request, state.to_sym)
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
