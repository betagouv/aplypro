# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::InduEtranger, type: :model do
  describe "fragment" do
    let(:pfmp) { create(:pfmp, :rectified) }

    before do
      pfmp.student.update(
        address_line1: "A" * 38,
        address_line2: "B" * 38,
        address_city: "Cool City",
        address_postal_code: 66_666
      )
    end

    describe "validation" do
      it { is_expected.to validate_presence_of(:localiteetranger) }
      it { is_expected.to validate_presence_of(:bureaudistribetranger) }
      it { is_expected.to validate_presence_of(:codetypeadr) }
    end

    it_behaves_like "an XML-fragment producer" do
      let(:entity) { described_class.from_schooling(pfmp.schooling) }
      let(:probe) { %w[codetypeadr PRINCIPALE] }

      it "uses the establishment details for the address" do
        expect(document.at("localiteetranger").text).to eq "Cool City"
        expect(document.at("bureaudistribetranger").text).to eq  66_666.to_s
      end

      context "when the addresse is too long" do
        before do
          pfmp.student.update(
            address_city: "A" * 50
          )
        end

        it "errors" do
          expect { document.to_s }.to raise_error ActiveModel::ValidationError
        end
      end
    end
  end
end
