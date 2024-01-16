# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::DossierMapper do
  subject(:mapper) { described_class.new(student) }

  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }

  describe "#valeur" do
    before { schooling.establishment.update!(postal_code: "34000") }

    it "returns the establishment's region code left-padded with a 0" do
      expect(mapper.valeur).to eq "034"
    end
  end
end
