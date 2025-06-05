# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Sync::StudentJob, :student_api do
  let(:classe) { create(:classe, establishment: establishment) }
  let(:schooling) { create(:schooling, classe: classe) }
  let(:student) { schooling.student }

  shared_examples "maps all the extra fields correctly" do
    describe "attributes mapping" do
      %i[
        birthdate
        address_line1
        address_postal_code
        address_city_insee_code
        address_country_code
        birthplace_city_insee_code
        birthplace_country_insee_code
        biological_sex
      ].each do |attribute|
        it "updates the `#{attribute}` attribute" do
          expect { described_class.new(schooling).perform_now }.to change(student, attribute)
        end
      end
    end
  end

  context "when the student is from SYGNE" do
    let(:establishment) { create(:establishment, :sygne_provider) }

    let(:token) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }
    let(:payload) { build(:sygne_student_info).to_json }

    before do
      WebmockHelpers.mock_sygne_token(token)
      WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, payload)
    end

    include_examples "maps all the extra fields correctly"

    context "when the student was not found before" do
      before { student.update!(ine_not_found: true) }

      it "does not make a request the API" do
        endpoint = StudentsApi::Sygne::Api.establishment_students_endpoint(uai: establishment.uai)

        described_class.perform_now(schooling)

        expect(WebMock).not_to have_requested(:get, endpoint)
      end
    end

    context "when the addresses informations change and have a payment request rejected" do
      let(:payment_request) do
        create(:asp_payment_request, :rejected,
               reason: I18n.t("asp.errors.rejected.returns.payment_coordinates_blocked"))
      end

      let(:pfmp) { payment_request.pfmp }

      before { described_class.perform_now(student.current_schooling) }

      it "does not create a new payment request" do
        expect(pfmp.latest_payment_request).to eq(payment_request)
      end

      it "creates a new payment request" do
        student.update!(address_line1: Faker::Address.street_name)
        student.current_schooling.pfmps << pfmp
        described_class.perform_now(student.current_schooling)

        expect(pfmp.latest_payment_request).not_to eq(payment_request)
      end
    end

    context "when the API responds with a 404" do
      before do
        WebMock
          .stub_request(:get, %r{#{ENV.fetch('APLYPRO_SYGNE_URL')}eleves/#{student.ine}})
          .to_return status: 404
      end

      it "stores it on the student" do
        expect { described_class.perform_now(schooling) }.to change(student, :ine_not_found).from(false).to(true)
      end
    end
  end

  context "when the student is from FREGATA" do
    let(:establishment) { create(:establishment, :fregata_provider) }
    let(:payload) { build_list(:fregata_student, 1, ine_value: student.ine).to_json }

    before do
      WebmockHelpers.mock_fregata_students_with(establishment.uai, payload)
    end

    include_examples "maps all the extra fields correctly"
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
