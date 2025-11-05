# frozen_string_literal: true

require "rails_helper"

describe Stats::Indicator::Ratio::StudentsPaid do
  let(:current_start_year) { SchoolYear.current.start_year }

  describe "with multiple paid PFMPs per student" do
    before do
      student = create(:student, :asp_ready)
      classe = create(:classe, school_year: SchoolYear.current)
      schooling = create(:schooling, :with_attributive_decision, student: student, classe: classe)

      2.times do
        payment_request = create(:asp_payment_request, :paid)
        payment_request.pfmp.update!(schooling: schooling)
      end
    end

    it "counts each student only once" do
      count = Stats::Indicator::Count::StudentsPaid.new(current_start_year).global_data
      expect(count).to eq(1)
    end

    it "does not exceed 100%" do
      ratio = described_class.new(current_start_year).global_data
      expect(ratio).to be <= 1.0
    end
  end
end
