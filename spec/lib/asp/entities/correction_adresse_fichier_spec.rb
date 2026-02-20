# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::CorrectionAdresseFichier do
  subject(:file) { described_class.new(payment_requests) }

  let(:payment_requests) { create_list(:asp_payment_request, 3, :ready) }

  it "produces valid documents" do
    log_on_failure = -> { file.errors.each { |e| Rails.logger.debug "ASP validation error: #{e.message}\n" } }

    expect { file.validate! }.not_to raise_error, log_on_failure
  end

  describe "to_xml" do
    subject(:document) { Nokogiri::XML(file.to_xml) }

    before { mock_entity("CorrectionAdresseEnregistrement") }

    it "includes the config" do
      expect(document % "PARAMETRAGE").not_to be_nil
    end

    context "when there are multiple students" do
      it "includes one record per payment" do
        expect(document / "CORRECTIONADRESSEENREGISTREMENT").to have(3).elements
      end
    end
  end
end
