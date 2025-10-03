# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/MultipleMemoizedHelpers

RSpec.describe IdentityMappers::Base do
  let(:mapper) { described_class.new(attributes) }
  let(:fredurneresp) { build(:fredurneresp, uai: "dir") }
  let(:fredufonctadm) { "DIR" }
  let(:fredurne) { [build(:fredurne, uai: "normal")] }
  let(:freduresdel) { [build(:freduresdel, uai: "delegated")] }

  let(:attributes) do
    {
      "FrEduRneResp" => fredurneresp,
      "FrEduRne" => fredurne,
      "FrEduFonctAdm" => fredufonctadm,
      "FrEduResDel" => freduresdel
    }
  end

  describe "#all_indicated_uais" do
    subject(:result) { mapper.all_indicated_uais }

    it { is_expected.to contain_exactly "normal", "dir", "delegated" }

    context "when there are irrelevant establishments" do
      before do
        allow(Establishment).to receive(:accepted_type?).with("CLG").and_return false
        allow(Establishment).to receive(:accepted_type?).with("LYC").and_return true
      end

      let(:fredurne) { [build(:fredurne, uai: "normal"), build(:fredurne, uai: "normal wrong", tty_code: "CLG")] }
      let(:fredurneresp) { [build(:fredurneresp, uai: "dir"), build(:fredurneresp, uai: "dir wrong", tty_code: "CLG")] }
      let(:freduresdel) { build(:freduresdel, uai: "deleg wrong", tty_code: "CLG") }

      it { is_expected.not_to include "normal wrong", "dir wrong", "deleg wrong" }
    end

    context "when there are no values" do
      let(:fredurneresp) { ["X"] }
      let(:fredurne) { ["X"] }
      let(:freduresdel) { ["X"] }

      it { is_expected.to be_empty }
    end

    context "when some establishments are not included in the perimeter" do
      before do
        %w[A B C].each { |uai| allow(Exclusion).to receive(:establishment_excluded?).with(uai, nil).and_return true }

        allow(Exclusion).to receive(:establishment_excluded?).with("Z", nil).and_return false
      end

      let(:fredurne) { [build(:fredurne, uai: "A"), build(:fredurne, uai: "Z")] }
      let(:fredurneresp) { build(:fredurneresp, uai: "B") }
      let(:freduresdel) { build(:freduresdel, uai: "C") }

      it "filters them out" do
        expect(result).to contain_exactly "Z"
      end
    end

    context "when some establishments are added in the perimeter" do
      let(:fredurne) { build(:fredurne, uai: "9760167C", tty_code: "CLG") }
      let(:fredurneresp) { build(:fredurneresp, uai: "1234", tty_code: "CLG") }
      let(:freduresdel) { build(:freduresdel, uai: "C", tty_code: "CLG") }

      it "filters them in" do
        expect(result).to contain_exactly "9760167C"
      end
    end
  end

  describe "#establishments_authorised_for" do
    subject(:result) { mapper.establishments_authorised_for(email) }

    let(:mapper) { IdentityMappers::Fim.new(attributes) }
    let(:email) { "jean.valjean@ac-paris.fr" }

    it "contains the delegated establishment" do
      expect(result.pluck(:uai)).to eq ["delegated"]
    end

    context "when there is no attributes" do
      let(:attributes) { {} }

      it { is_expected.to be_empty }
    end

    context "when there is an invitation for the email, even for an UAI not in the FrEduRne" do
      let(:establishment) { create(:establishment, uai: "invited") }
      let(:invitation) { create(:establishment_invitation, email: email, establishment: establishment) }

      before do
        invitation
      end

      it "contains the invited establishment" do
        expect(result.pluck(:uai)).to eq %w[invited delegated]
      end
    end
  end

  describe "#responsibility_uais" do
    context "when there is a FrEduRneResp" do
      subject(:result) { mapper.responsibility_uais }

      context "when it's a not the right kind of school" do
        let(:fredurneresp) { [build(:fredurneresp, uai: "dir wrong", tty_code: "CLG")] }

        it { is_expected.to be_empty }
      end

      context "when it's the proper kind of school" do
        it { is_expected.to contain_exactly "dir" }
      end

      context "when the administration function is not DIR" do
        let(:fredufonctadm) { "ADM" }

        it { is_expected.to be_empty }
      end

      context "when the FrEduRneResp value is plain" do
        let(:fredurneresp) { "0441550W$UAJ$PU$N$T3$LYC$340" }

        it { is_expected.not_to be_empty }
      end
    end

    context "when there is no FrEduRneResp" do
      it "is empty" do
        attributes.delete("FrEduRneResp")

        expect(described_class.new(attributes).responsibility_uais).to be_empty
      end
    end
  end

  describe "#aplypro_delegation?" do
    subject(:result) { mapper.aplypro_delegation?(delegation_url) }

    context "with a valid aplypro delegation line" do
      let(:delegation_url) { "/redirectionhub/redirect.jsp?applicationname=aplypro" }

      it { is_expected.to be true }
    end

    context "with a valid aplypro delegation line with /mdp/ at the beginning" do
      let(:delegation_url) { "/mdp/redirectionhub/redirect.jsp?applicationname=aplypro" }

      it { is_expected.to be true }
    end

    context "with a valid aplypro_etab delegation line" do
      let(:delegation_url) { "/redirectionhub/redirect.jsp?applicationname=aplypro_etab" }

      it { is_expected.to be true }
    end

    context "with a invalid delegation line" do
      let(:delegation_url) { "/redirectionhub/redirect.jsp?applicationname=other_app" }

      it { is_expected.to be false }
    end
  end

  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
