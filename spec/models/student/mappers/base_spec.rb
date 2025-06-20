# frozen_string_literal: true

require "rails_helper"

describe Student::Mappers::Base do
  subject(:mapper) { described_class }

  let(:uai) { create(:establishment).uai }
  let(:data) { {} }

  describe "#current_school_year?" do
    let(:result) { mapper.new(data, uai).current_school_year?(start_date) }

    context "when there is no start date" do
      let(:start_date) { nil }

      it { expect(result).to be false }
    end

    context "when the start date is before the current school year range" do
      let(:start_date) { "#{SchoolYear.current.start_year - 1}-12-31" }

      it { expect(result).to be false }
    end

    context "when the start date is equal to the current school year range" do
      let(:start_date) { "#{SchoolYear.current.start_year}-12-31" }

      it { expect(result).to be true }
    end
  end
end
