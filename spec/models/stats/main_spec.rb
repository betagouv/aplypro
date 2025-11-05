# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Stats::Main do
  let(:main) { described_class.new(SchoolYear.current.start_year) }

  describe "#global_data" do
    subject(:data) { main.global_data }

    include_context "when there is data for global stats"

    it "computes the right percentages" do
      expect(data.length).to eq(1)
      expect(data.first).to include(
        yearly_sum: 500, schoolings_count: 5, attributive_decisions_count: 2,
        attributive_decisions_ratio: 0.4, students_count: 5, ribs_count: 2,
        ribs_ratio: 0.4, pfmps_count: 5, pfmps_validated_count: 2,
        payment_requests_sent_count: 2, payment_requests_integrated_count: 0
      )
    end
  end

  describe "#bops_data" do
    subject(:data) { main.bops_data }

    include_context "when there is data for stats per bops"

    it "computes the correct percentages" do
      expect(data.length).to eq(4)
      expect(data.pluck(:BOP)).to contain_exactly("ENPU", "ENPR", "MASA", "MER")

      enpu = data.find { |r| r[:BOP] == "ENPU" }
      expect(enpu[:attributive_decisions_ratio]).to eq(0.25)
      expect(enpu[:yearly_sum]).to eq(400)
      expect(enpu[:schoolings_count]).to eq(4)
      expect(enpu[:payment_requests_sent_count]).to eq(1)

      enpr = data.find { |r| r[:BOP] == "ENPR" }
      expect(enpr[:attributive_decisions_ratio]).to eq(0.8)
      expect(enpr[:yearly_sum]).to eq(500)
    end
  end

  describe "#menj_academies_data" do
    subject(:data) { main.menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it "computes the correct percentages" do
      expect(data.length).to eq(3)
      expect(data.pluck(:Académie)).to contain_exactly("Bordeaux", "Montpellier", "Paris")

      bordeaux = data.find { |r| r[:Académie] == "Bordeaux" }
      expect(bordeaux).to include(
        attributive_decisions_ratio: 0.25,
        yearly_sum: 400,
        schoolings_count: 4,
        payment_requests_paid_count: 1
      )
    end
  end

  describe "#establishments_data" do
    subject(:data) { main.establishments_data }

    include_context "when there is data for stats per establishments"

    it "computes the correct percentages" do
      expect(data.length).to eq(3)
      expect(data.pluck(:UAI)).to contain_exactly("0000000A", "0000000B", "0000000C")
      establishment_a = data.find { |r| r[:UAI] == "0000000A" }
      expect(establishment_a).to include(
        "Nom de l'établissement": "0000000A", Ministère: "MINISTERE DE L'EDUCATION NATIONALE",
        Académie: "Marseille", "Privé/Public": "Public", attributive_decisions_ratio: 0.25,
        yearly_sum: 400, schoolings_count: 4
      )
    end
  end

  describe "#csv_of" do
    subject(:csv_string) { main.csv_of(data) }

    let(:data) do
      [
        %w[title1 title2 title3],
        [0.999999, nil, 0.1],
        [4.0 / 7, 0.0 / 0, 1.0 / 0]
      ]
    end

    it "formats the data into a csv string" do
      expect(csv_string).to eq("title1\ttitle2\ttitle3\n0,999999\t0\t0,1\n0,5714285714285714\t0\tInfini")
    end
  end
end
