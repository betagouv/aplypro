# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::RibMapper do
  subject(:mapper) { described_class.new(student) }

  let(:rib) { create(:rib) }
  let(:student) { rib.student }

  context "when the BIC ends in 'XXX'" do
    before { rib.update!(bic: "ASTPGB2LXXX") }

    it "removes those characters" do
      expect(mapper.bic).to eq "ASTPGB2L"
    end
  end
end
