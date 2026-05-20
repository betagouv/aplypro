# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Entity do
  describe "#adresse_entity_class" do
    subject(:entity) do
      instance = described_class.new
      instance.instance_variable_set(:@payment_request, payment_request)
      instance
    end

    let(:payment_request) { create(:asp_payment_request, :sendable) }
    let(:student) { payment_request.pfmp.student }

    before { student.update!(address_country_code: "100") }

    context "when the student is in France with no recovery history" do
      it { expect(entity.adresse_entity_class).to eq ASP::Entities::Adresse::France }
    end

    context "when the student lives abroad with no recovery history" do
      before { student.update!(address_country_code: "099") }

      it { expect(entity.adresse_entity_class).to eq ASP::Entities::Adresse::Etranger }
    end

    context "when the student had a recovery payment and lives in France" do
      let(:recovery_pfmp) { create(:pfmp, :rectified_with_recovery) }
      let(:payment_request) { create(:asp_payment_request, :sendable, pfmp: recovery_pfmp) }

      before { recovery_pfmp.student.update!(address_country_code: "100") }

      it { expect(entity.adresse_entity_class).to eq ASP::Entities::Adresse::CorrectionFrance }
    end

    context "when the student had a recovery payment and lives abroad" do
      let(:recovery_pfmp) { create(:pfmp, :rectified_with_recovery) }
      let(:payment_request) { create(:asp_payment_request, :sendable, pfmp: recovery_pfmp) }

      before { recovery_pfmp.student.update!(address_country_code: "099") }

      it { expect(entity.adresse_entity_class).to eq ASP::Entities::Adresse::CorrectionEtranger }
    end
  end
end
