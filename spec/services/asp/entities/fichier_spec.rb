# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Fichier do
  subject(:file) { described_class.new(payments) }

  let(:payments) { create_list(:payment, 1) }

  let(:entity_double) { instance_double(ASP::Entities::PersonnePhysique) }

  before do
    allow(ASP::Entities::PersonnePhysique).to receive(:from_student).and_return(entity_double)

    allow(entity_double).to receive(:to_xml)
  end

  describe "to_xml" do
    subject(:document) { Nokogiri::XML(file.to_xml) }

    it "includes the config" do
      expect(document % "PARAMETRAGE").not_to be_nil
    end

    context "when there are multiple students" do
      let(:payments) { create_list(:payment, 3) }

      it "includes one record per payment" do
        expect(document / "ENREGISTREMENT").to have(payments.length).elements
      end
    end
  end
end
