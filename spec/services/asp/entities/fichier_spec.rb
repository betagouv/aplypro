# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Fichier do
  subject(:file) { described_class.new(payments) }

  let(:payments) { create_list(:payment, 1) }

  describe "to_xml" do
    subject(:document) { Nokogiri::XML(file.to_xml) }

    let(:person_double) { instance_double(ASP::Entities::PersonnePhysique) }
    let(:address_double) { instance_double(ASP::Entities::Adresse) }
    let(:rib_double) { instance_double(ASP::Entities::CoordonneesPaiement) }

    before do
      allow(ASP::Entities::PersonnePhysique).to receive(:from_student).and_return(person_double)
      allow(ASP::Entities::Adresse).to receive(:from_student).and_return(address_double)
      allow(ASP::Entities::CoordonneesPaiement).to receive(:from_student).and_return(rib_double)

      allow(person_double).to receive(:to_xml)
      allow(address_double).to receive(:to_xml)
      allow(rib_double).to receive(:to_xml)
    end

    it "includes the config" do
      expect(document % "PARAMETRAGE").not_to be_nil
    end

    context "when the student isn't known" do
      # FIXME: figure out if we always have to include it or not
      it "includes its address" do
        expect(document / "ENREGISTREMENT/INDIVIDU/ADRESSESINDIVIDU").to be_present
      end
    end

    context "when there are multiple students" do
      let(:payments) { create_list(:payment, 3) }

      it "includes one record per payment" do
        expect(document / "ENREGISTREMENT").to have(3).elements
      end
    end
  end
end
