# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::DossierMapper do
  subject(:mapper) { described_class.new(payment) }

  let(:student) { create(:student) }
  let(:payment) { create(:payment) }

  before { payment.pfmp.update!(student: student) }

  describe "#valeur" do
    before { student.establishment.update!(postal_code: "34000") }

    it "returns the establishment's region code left-padded with a 0" do
      expect(mapper.valeur).to eq "034"
    end
  end
end
