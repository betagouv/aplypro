# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::AdresseMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }
  let(:student) { payment_request.student }

  described_class::MAPPING.each do |name, mapping|
    it "maps to the student's`#{mapping}'" do
      expect(mapper.send(name)).to eq student[mapping]
    end
  end
end
