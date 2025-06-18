# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::InduFrance, type: :model do
  describe "fragment" do
    let(:pfmp) { create(:pfmp, :rectified) }

    before do
      pfmp.student.update(
        address_line1: "A" * 38,
        address_line2: "B" * 38
      )
    end

    describe "validation" do
      it { is_expected.to validate_presence_of(:pointremise) }
      it { is_expected.to validate_presence_of(:codepostalcedex) }
      it { is_expected.to validate_presence_of(:codecominsee) }
      it { is_expected.to validate_presence_of(:codeinseepays) }
      it { is_expected.to validate_presence_of(:codetypeadr) }
    end

    it_behaves_like "an XML-fragment producer" do
      let(:entity) { described_class.from_payment_request(pfmp.latest_payment_request) }
      let(:probe) { %w[codetypeadr PRINCIPALE] }

      it "uses the establishment details for the address" do
        expect(document.at("pointremise").text).to eq "A" * 38
        expect(document.at("cpltdistribution").text).to eq  "B" * 38
      end

      context "when the addresse is too long" do
        before do
          pfmp.student.update(
            address_line1: "A" * 50,
            address_line2: "B" * 50
          )
        end

        it "errors" do
          expect { document.to_s }.to raise_error ActiveModel::ValidationError
        end
      end
    end
  end
end
