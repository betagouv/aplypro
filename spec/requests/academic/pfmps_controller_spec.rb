# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::PfmpsController do
  let(:payment_request) { create(:asp_payment_request, :paid) }
  let(:pfmp) { payment_request.pfmp }
  let(:student) { pfmp.student }
  let(:user) { create(:academic_user) }

  before do
    sign_in(user)
    allow_any_instance_of(Academic::ApplicationController).to receive(:selected_academy) # rubocop:disable RSpec/AnyInstance
      .and_return(pfmp.establishment.academy_code)
    allow_any_instance_of(Academic::ApplicationController).to receive(:authorised_academy_codes) # rubocop:disable RSpec/AnyInstance
      .and_return([pfmp.establishment.academy_code])
  end

  shared_examples "the historical payment IBAN" do
    it "displays the IBAN used on both the PFMP list and detail page" do
      [academic_student_path(student), academic_student_pfmp_path(student, pfmp)].each do |path|
        get path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(ApplicationController.helpers.mask_iban(previous_iban))
      end
    end
  end

  context "when the student's bank details have changed" do
    let(:previous_iban) { payment_request.rib.iban }

    before do
      previous_iban
      payment_request.rib.archive!
      create(:rib, student: student, establishment: pfmp.establishment)
    end

    include_examples "the historical payment IBAN"

    context "when an old payment has no saved RIB" do
      let(:previous_iban) { payment_request.reconstructed_iban }

      before { payment_request.update!(rib: nil) }

      include_examples "the historical payment IBAN"
    end
  end

  context "when no historical bank details are available" do
    let(:payment_request) { create(:asp_payment_request, :pending) }

    it "does not substitute the student's current IBAN" do
      get academic_student_pfmp_path(student, pfmp)

      expect(response.body).to include("Non renseigné")
      expect(response.body).not_to include(ApplicationController.helpers.mask_iban(student.rib(pfmp.establishment).iban))
    end
  end
end
