# frozen_string_literal: true

require "rails_helper"

RSpec.describe PreparePaymentRequestJob, :student_api do
  let(:payment_request) { create(:asp_payment_request, :sendable) }

  before do
    ine = payment_request.student.ine

    WebmockHelpers.mock_sygne_token
    WebmockHelpers.mock_sygne_student_endpoint_with(
      ine,
      build(:sygne_student_info, ine_value: ine).to_json
    )
  end

  it "tries to get fresh information first" do
    api = payment_request.schooling.establishment.students_api

    endpoint = api.student_endpoint(ine: payment_request.student.ine)

    described_class.perform_now(payment_request)

    expect(a_request(:get, endpoint)).to have_been_made
  end

  context "when the request is ready" do
    it "marks it ready" do
      expect { described_class.perform_now(payment_request) }
        .to change(payment_request, :current_state).from("pending").to("ready")
    end
  end
end
