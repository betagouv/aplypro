# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Sygne::Mappers::AddressMapper do
  subject(:mapper) { described_class.new }

  let(:data) { build(:sygne_student_info) }

  let(:expected) do
    {
      address_line1: [data['adrResidenceEle']['adresseLigne1'], data['adrResidenceEle']['adresseLigne2'],
                      data['adrResidenceEle']['adresseLigne3'], data['adrResidenceEle']['adresseLigne4']].join(" "),
      address_postal_code: data["adrResidenceEle"]["codePostal"],
      address_city: data["adrResidenceEle"]["libelleCommune"],
      address_city_insee_code: data["adrResidenceEle"]["codeCommuneInsee"],
      address_country_code: data["adrResidenceEle"]["codePays"],
      birthplace_city_insee_code: data["inseeCommuneNaissance"],
      birthplace_country_insee_code: data["inseePaysNaissance"]
    }
  end

  it "maps the data correctly" do
    expect(mapper.call(data)).to eq expected
  end

  context "when address_line2 is nil" do
    before { data["adrResidenceEle"]["adresseLigne2"] = nil }

    it "maps addresses correctly" do
      expect(mapper.call(data)[:address_line1]).to eq [data["adrResidenceEle"]["adresseLigne1"],
                                                       data["adrResidenceEle"]["adresseLigne3"],
                                                       data["adrResidenceEle"]["adresseLigne4"]].join(" ")
    end
  end
end
