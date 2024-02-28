# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment do
  subject(:payment) { create(:payment) }

  it { is_expected.to belong_to(:pfmp) }
  it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }

  describe ".paid" do
    subject { described_class.paid }

    let(:student) { create(:student, :with_all_asp_info) }
    let(:payment) { create(:pfmp, :validated, student: student).payments.last }

    context "when there is a successful payment request attached to it" do
      before do
        create(:asp_payment_request, :paid, payment: payment)
      end

      it { is_expected.to include payment }
    end

    context "when there is no successful payment request attached to it" do
      it { is_expected.not_to include payment }
    end

    context "when the request has merely been integrated" do
      before do
        create(:asp_payment_request, :integrated, payment: payment)
      end

      it { is_expected.not_to include payment }
    end
  end
end
