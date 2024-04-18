# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaymentRequestsController do
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: schooling.classe.establishment) }
  let(:pfmp) { create(:pfmp, schooling: schooling) }

  before { sign_in(user) }

  describe "POST /create_payment_request" do
    let(:pfmp_manager) { instance_double(PfmpManager) }

    before do
      allow(PfmpManager).to receive(:new).and_return(pfmp_manager)
      allow(pfmp_manager).to receive(:create_new_payment_request!)
    end

    context "when the director is confirmed" do
      it "calls the PfmpManager" do
        post class_schooling_payment_requests_path(class_id: schooling.classe.id, schooling_id: schooling.id,
                                                   id: pfmp.id), params: { confirmed_director: "1" }
        expect(pfmp_manager).to have_received(:create_new_payment_request!)
      end
    end

    context "when the director is not confirmed" do
      it "does not call the PfmpManager" do
        post class_schooling_payment_requests_path(class_id: schooling.classe.id, schooling_id: schooling.id,
                                                   id: pfmp.id), params: { confirmed_director: "0" }
        expect(pfmp_manager).not_to have_received(:create_new_payment_request!)
      end
    end
  end
end
