# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe FetchStudentInformationJob, :student_api do
  let(:classe) { create(:classe, establishment: establishment) }
  let(:schooling) { create(:schooling, classe: classe) }
  let(:student) { schooling.student }

  shared_examples "maps all the extra fields correctly" do
    describe "attributes mapping" do
      %i[
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
        endpoint = StudentsApi::Sygne::Api.new(establishment.uai).student_endpoint(student.ine)

        described_class.perform_now(schooling)

        expect(WebMock).not_to have_requested(:get, endpoint)
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
