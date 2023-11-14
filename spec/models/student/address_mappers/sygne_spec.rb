# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Student::AddressMappers::Sygne do
  let(:data) { build(:sygne_student_info) }

  let(:line_one) { data["adrResidenceEle"]["adresseLigne1"] }
  let(:line_two) { data["adrResidenceEle"]["adresseLigne2"] }
  let(:postal_code) { data["adrResidenceEle"]["codePostal"] }
  let(:city) { data["adrResidenceEle"]["libelleCommune"] }
  let(:city_insee_code) { data["adrResidenceEle"]["codeCommuneInsee"] }
  let(:country_code) { data["adrResidenceEle"]["codePays"] }

  describe "mapper" do
    subject { described_class.new(data).address_attributes }

    it { is_expected.to include(address_line1: line_one) }
    it { is_expected.to include(address_line2: line_two) }
    it { is_expected.to include(city: city) }
    it { is_expected.to include(city_insee_code: city_insee_code) }
    it { is_expected.to include(country_code: country_code) }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
