# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse::InduEtranger, type: :model do
  describe "fragment" do
    let(:pfmp) { create(:pfmp, :rectified) }

    before do
      pfmp.student.update(
        address_line1: "A" * 50,
        address_line2: "B" * 50
      )
    end

    describe "validation" do
      it { is_expected.to validate_presence_of(:localiteetranger) }
      it { is_expected.to validate_presence_of(:bureaudistribetranger) }
      it { is_expected.to validate_presence_of(:codetypeadr) }
    end

    it_behaves_like "an XML-fragment producer" do
      let(:entity) { described_class.from_payment_request(pfmp.latest_payment_request) }
      let(:probe) { %w[codetypeadr PRINCIPALE] }

      it "uses the establishment details for the address" do # rubocop:disable RSpec/MultipleExpectations
        expect(document.at("localiteetranger").text).to eq "A" * 38
        expect(document.at("bureaudistribetranger").text).to eq  "B" * 38
      end
    end
  end
end
