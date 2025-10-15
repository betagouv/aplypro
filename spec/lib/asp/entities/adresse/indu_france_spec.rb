# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::InduFrance, type: :model do
  describe "fragment" do
    let(:pfmp) { create(:pfmp, :rectified) }

    before do
      pfmp.student.update(
        address_line1: "A" * 28,
        address_line2: "B" * 38
      )
    end

    describe "validation" do
      it { is_expected.to validate_presence_of(:libellevoie) }
      it { is_expected.to validate_presence_of(:codepostalcedex) }
      it { is_expected.to validate_presence_of(:codecominsee) }
      it { is_expected.to validate_presence_of(:codeinseepays) }
      it { is_expected.to validate_presence_of(:codetypeadr) }
    end

    it_behaves_like "an XML-fragment producer" do
      let(:entity) { described_class.from_payment_request(pfmp.latest_payment_request) }
      let(:probe) { %w[codetypeadr PRINCIPALE] }

      it "uses the establishment details for the address" do
        expect(document.at("libellevoie").text).to eq "A" * 28
        expect(document.at("cpltdistribution").text).to eq  "B" * 38
      end

      context "when the address is too long and contains no abbreviatable words" do
        before do
          pfmp.student.update(
            address_line1: "A" * 29,
            address_line2: "B" * 50
          )
        end

        it "errors" do
          expect { document.to_s }.to raise_error ActiveModel::ValidationError
        end
      end

      context "when the address is too long and contains abbreviatable words" do
        before do
          pfmp.student.update(
            address_line1: "Résidence Parc Boulevard Victor",
            address_line2: "Appartement 12 Impasse du Moulin Ouest Sud"
          )
        end

        it "abbreviates the address fields to fit within limits" do
          expect(document.at("libellevoie").text).to eq "Rdce Parc Bvd Victor"
          expect(document.at("cpltdistribution").text).to eq "Apt 12 Imp du Moulin Ouest Sud"
        end
      end

      context "when the address is within limits and contains abbreviatable words" do
        before do
          pfmp.student.update(
            address_line1: "Boulevard Victor",
            address_line2: "Résidence A"
          )
        end

        it "does not abbreviate the address fields" do
          expect(document.at("libellevoie").text).to eq "Boulevard Victor"
          expect(document.at("cpltdistribution").text).to eq "Résidence A"
        end
      end
    end
  end
end
