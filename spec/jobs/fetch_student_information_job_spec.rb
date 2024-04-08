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

  shared_examples "updates the schooling status" do |factory_name|
    let(:factory) { factory_name.to_sym }
    let(:status) { :apprentice }

    let(:student_data) do
      build(
        factory,
        status,
        classe_label: schooling.classe.label,
        ine: student.ine,
        uai: establishment.uai,
        mef_value: schooling.classe.mef.code.concat("0")
      ).to_json
    end

    it "updates the schooling's status code" do
      expect { described_class.new(schooling).perform_now }
        .to change { schooling.reload.status }.to(status.to_s)
    end
  end

  context "when the student is from SYGNE" do
    let(:establishment) { create(:establishment, :sygne_provider) }

    let(:token) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }
    let(:payload) { Rails.root.join("mock/data/sygne-student.json").read }

    before do
      WebmockHelpers.mock_sygne_token(token)
      WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, payload)
    end

    include_examples "maps all the extra fields correctly"

    include_examples "updates the schooling status", "sygne_student_info" do
      let(:payload) { student_data }
    end

    context "when the student was not found before" do
      before { student.update!(ine_not_found: true) }

      it "does not make a request the API" do
        endpoint = StudentApi::Sygne.new(establishment.uai).student_endpoint(student.ine)

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
    let(:payload) { Rails.root.join("mock/data/fregata-students.json").read }

    before do
      student.update!(ine: JSON.parse(payload).first["apprenant"]["ine"])

      WebmockHelpers.mock_fregata_students_with(establishment.uai, payload)
    end

    include_examples "maps all the extra fields correctly"

    include_examples "updates the schooling status", "fregata_student" do
      let(:payload) { [JSON.parse(student_data)].to_json }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
