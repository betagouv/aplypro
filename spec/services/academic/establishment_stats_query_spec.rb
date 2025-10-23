# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::EstablishmentStatsQuery do
  subject(:query) { described_class.new(academy_code, school_year) }

  let(:academy_code) { "01" }
  let(:school_year) { create(:school_year) }
  let(:establishment) { create(:establishment, academy_code: academy_code) }

  describe "#establishments_data_summary" do
    context "with establishments having PFMPs" do
      before do
        classe = create(:classe, establishment: establishment, school_year: school_year)
        schooling = create(:schooling, classe: classe)
        pfmp = create(:pfmp, schooling: schooling, amount: 1000).tap(&:validate!)
        create(:asp_payment_request, :paid, pfmp: pfmp)
      end

      it "returns summary data for establishments" do
        result = query.establishments_data_summary([establishment.id])

        expect(result).to have_key(establishment.uai)
        expect(result[establishment.uai]).to include(
          :uai,
          :name,
          :schooling_count,
          :payable_amount,
          :paid_amount
        )
      end

      it "includes schooling count" do
        result = query.establishments_data_summary([establishment.id])
        expect(result[establishment.uai][:schooling_count]).to eq(1)
      end

      it "includes validated amount" do
        result = query.establishments_data_summary([establishment.id])
        expect(result[establishment.uai][:payable_amount]).to eq(1000)
      end

      it "includes paid amount" do
        result = query.establishments_data_summary([establishment.id])
        expect(result[establishment.uai][:paid_amount]).to eq(1000)
      end

      it "sorts by paid amount descending" do
        establishment2 = create(:establishment, academy_code: academy_code)
        classe2 = create(:classe, establishment: establishment2, school_year: school_year)
        schooling2 = create(:schooling, classe: classe2)
        pfmp2 = create(:pfmp, schooling: schooling2, amount: 2000).tap(&:validate!)
        create(:asp_payment_request, :paid, pfmp: pfmp2)

        result = query.establishments_data_summary([establishment.id, establishment2.id])

        expect(result.keys).to eq([establishment2.uai, establishment.uai])
      end
    end

    context "with no establishments" do
      it "returns empty hash" do
        result = query.establishments_data_summary([])
        expect(result).to eq({})
      end
    end

    context "with establishments but no PFMPs" do
      it "returns zero amounts" do
        result = query.establishments_data_summary([establishment.id])

        expect(result[establishment.uai][:payable_amount]).to eq(0)
        expect(result[establishment.uai][:paid_amount]).to eq(0)
      end
    end
  end
end
