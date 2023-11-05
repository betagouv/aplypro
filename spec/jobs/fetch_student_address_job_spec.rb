# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe FetchStudentAddressJob do
  let(:establishment) { create(:establishment, :with_fim_user) }
  let(:classe) { create(:classe, establishment: establishment) }
  let(:schooling) { create(:schooling, classe: classe) }
  let(:student) { schooling.student }

  let(:token) { JSON.generate({ access_token: "foobar", token_type: "Bearer" }) }
  let(:payload) { Rails.root.join("mock/data/sygne-student.json").read }
  let(:sygne_api) { instance_double(StudentApi::Sygne) }

  before do
    WebmockHelpers.mock_sygne_token_with(token)
    WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, payload)
  end

  describe "attributes mapping" do
    %i[
      address_line1
      address_line2
      postal_code
      city_insee_code
      city
      country_code
    ].each do |attribute|
      it "updates the `#{attribute}` attribute" do
        expect { described_class.new.perform(student) }.to change(student, attribute)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
