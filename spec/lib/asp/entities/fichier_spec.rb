# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Fichier do
  subject(:file) { described_class.new(requests) }

  let(:requests) { create_list(:asp_payment_request, 1, :ready) }

  describe "to_xml" do
    subject(:document) { Nokogiri::XML(file.to_xml) }

    before { mock_entity("Enregistrement") }

    it "includes the config" do
      expect(document % "PARAMETRAGE").not_to be_nil
    end

    context "when there are multiple students" do
      let(:requests) { create_list(:asp_payment_request, 3, :ready) }

      it "includes one record per payment" do
        expect(document / "ENREGISTREMENT").to have(3).elements
      end
    end
  end
end
