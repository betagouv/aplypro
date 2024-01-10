# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::StudentMapper do
  subject(:mapper) { described_class.new(student) }

  let(:student) { create(:student) }

  described_class::MAPPING.each do |name, mapping|
    it "maps to the student's`#{mapping}'" do
      expect(mapper.send(name)).to eq student[mapping]
    end
  end
end
