# frozen_string_literal: true

require "rails_helper"

require "./mock/apis/factories/api_student"

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Student::InfoMappers::Sygne do
  let(:data) { build(:sygne_student_info, :male) }

  let(:biological_sex) { data["codeSexe"] }
  let(:line_one) { data["adrResidenceEle"]["adresseLigne1"] }
  let(:line_two) { data["adrResidenceEle"]["adresseLigne2"] }
  let(:postal_code) { data["adrResidenceEle"]["codePostal"] }
  let(:city) { data["adrResidenceEle"]["libelleCommune"] }
  let(:city_insee_code) { data["adrResidenceEle"]["codeCommuneInsee"] }
  let(:country_code) { data["adrResidenceEle"]["codePays"] }
  let(:birthplace_city) { data["inseeCommuneNaissance"] }
  let(:birthplace_country) { data["inseePaysNaissance"] }

  describe "mapper" do
    subject { described_class.new(data, "0").attributes }

    it { is_expected.to include(address_line1: line_one) }
    it { is_expected.to include(address_line2: line_two) }
    it { is_expected.to include(address_city: city) }
    it { is_expected.to include(address_city_insee_code: city_insee_code) }
    it { is_expected.to include(address_country_code: country_code) }
    it { is_expected.to include(biological_sex: 1) }
    it { is_expected.to include(birthplace_city_insee_code: birthplace_city) }
    it { is_expected.to include(birthplace_country_insee_code: birthplace_country) }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
