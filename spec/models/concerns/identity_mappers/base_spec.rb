# frozen_string_literal: true

RSpec.describe IdentityMappers::Base do
  let(:attributes) { {} }

  describe "#responsibilities" do
    context "when there is a FrEduRneResp" do
      subject(:result) { described_class.new(attributes).responsibilities }

      let(:fredurneresp) { ["0441550W$UAJ$PU$N$T3$LYC$340"] }
      let(:fredufonctadm) { "DIR" }

      let(:attributes) do
        {
          "FrEduRneResp" => fredurneresp,
          "FrEduFonctAdm" => fredufonctadm
        }
      end

      context "when it's a not the right kind of school" do
        let(:fredurneresp) { "0441550W$UAJ$PU$N$T3$CLG$340" }

        it { is_expected.to be_empty }
      end

      context "when it's the proper kind of school" do
        it { is_expected.to contain_exactly a_hash_including(uai: "0441550W") }
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
        expect(described_class.new(attributes).responsibilities).to be_empty
      end
    end
  end
end
