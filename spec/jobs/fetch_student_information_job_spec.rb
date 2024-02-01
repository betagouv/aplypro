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
    let(:payload) { Rails.root.join("mock/data/sygne-student.json").read }
    let(:sygne_api) { instance_double(StudentApi::Sygne) }

    before do
      WebmockHelpers.mock_sygne_token_with(token)
      WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, payload)
    end

    include_examples "maps all the extra fields correctly"
  end

  context "when the student is from FREGATA" do
    let(:establishment) { create(:establishment, :fregata_provider) }
    let(:payload) { Rails.root.join("mock/data/fregata-students.json").read }

    before do
      student.update!(ine: JSON.parse(payload).first["apprenant"]["ine"])

      WebmockHelpers.mock_fregata_students_with(establishment.uai, payload)
    end

    include_examples "maps all the extra fields correctly"
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
