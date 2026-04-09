# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/asp"

describe ASP::Readers::CorrectionAdresseIntegrationsFileReader do
  subject(:reader) { described_class.new(io: data) }

  let(:asp_payment_request) { create(:asp_payment_request, :sent) }

  before do
    asp_payment_request.student.update!(asp_individu_id: "ind123")
    asp_payment_request.schooling.update!(asp_dossier_id: "doss456")
    asp_payment_request.pfmp.update!(asp_prestation_dossier_id: "preta789")
  end

  context "when all IDs match" do
    let(:data) do
      build(:asp_integration, payment_request: asp_payment_request,
                              idIndDoss: "ind123", idDoss: "doss456", idPretaDoss: "preta789")
    end

    it "does not raise" do
      expect { reader.process! }.not_to raise_error
    end
  end

  context "when IDs do not match" do
    let(:data) do
      build(:asp_integration, payment_request: asp_payment_request,
                              idIndDoss: "wrong_ind", idDoss: "wrong_doss", idPretaDoss: "preta789")
    end

    it "raises CorrectionAdresseIdMismatchError" do
      expect { reader.process! }.to raise_error(ASP::Errors::CorrectionAdresseIdMismatchError)
    end

    it "includes each mismatch in the error message" do
      expect { reader.process! }
        .to raise_error(ASP::Errors::CorrectionAdresseIdMismatchError, /idIndDoss.*idDoss/m)
    end
  end
end
