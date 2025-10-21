# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Stats::Main do
  let(:main) { described_class.new(SchoolYear.current.start_year) }

  describe "#global_data" do
    subject(:data) { main.global_data }

    include_context "when there is data for global stats"

    it "computes the right percentages" do # rubocop:disable RSpec/ExampleLength
      expect(data).to eq([
                           {
                             DA: 0.4,
                             "Coord. bancaires": 0.4,
                             "PFMPs validées": 0.4,
                             "Données élèves": 0.4,
                             "Mt. prêt envoi": 10.0,
                             "Mt. annuel total": 500,
                             Scolarités: 5,
                             "Toutes PFMPs": 5,
                             "Dem. envoyées": 2,
                             "Dem. intégrées": 0,
                             "Dem. payées": 0,
                             "Mt. payé": 0,
                             "Ratio PFMPs payées/payables": 0.0
                           }
                         ])
    end
  end

  describe "#bops_data" do
    subject(:data) { main.bops_data }

    include_context "when there is data for stats per bops"

    it "computes the correct percentages" do # rubocop:disable RSpec/ExampleLength
      expect(data).to eq([
                           {
                             BOP: "ENPU",
                             DA: 0.25,
                             "Coord. bancaires": 0.25,
                             "PFMPs validées": 0.25,
                             "Données élèves": 0.25,
                             "Mt. prêt envoi": 5.0,
                             "Mt. annuel total": 400,
                             Scolarités: 4,
                             "Toutes PFMPs": 4,
                             "Dem. envoyées": 1,
                             "Dem. intégrées": 1,
                             "Dem. payées": nil,
                             "Mt. payé": nil,
                             "Ratio PFMPs payées/payables": nil
                           },
                           {
                             BOP: "ENPR",
                             DA: 0.8,
                             "Coord. bancaires": 0.8,
                             "PFMPs validées": 0.8,
                             "Données élèves": 0.8,
                             "Mt. prêt envoi": 20.0,
                             "Mt. annuel total": 500,
                             Scolarités: 5,
                             "Toutes PFMPs": 5,
                             "Dem. envoyées": 4,
                             "Dem. intégrées": 4,
                             "Dem. payées": nil,
                             "Mt. payé": nil,
                             "Ratio PFMPs payées/payables": nil
                           },
                           {
                             BOP: "MASA",
                             DA: 0.4,
                             "Coord. bancaires": 0.4,
                             "PFMPs validées": 0.4,
                             "Données élèves": 0.4,
                             "Mt. prêt envoi": 10.0,
                             "Mt. annuel total": 500,
                             Scolarités: 5,
                             "Toutes PFMPs": 5,
                             "Dem. envoyées": 2,
                             "Dem. intégrées": 2,
                             "Dem. payées": nil,
                             "Mt. payé": nil,
                             "Ratio PFMPs payées/payables": nil
                           },
                           {
                             BOP: "MER",
                             DA: 4.0 / 7,
                             "Coord. bancaires": 4.0 / 7,
                             "PFMPs validées": 4.0 / 7,
                             "Données élèves": 4.0 / 7,
                             "Mt. prêt envoi": 20.0,
                             "Mt. annuel total": 700,
                             Scolarités: 7,
                             "Toutes PFMPs": 7,
                             "Dem. envoyées": 4,
                             "Dem. intégrées": 4,
                             "Dem. payées": nil,
                             "Mt. payé": nil,
                             "Ratio PFMPs payées/payables": nil
                           }
                         ])
    end
  end

  describe "#menj_academies_data" do
    subject(:data) { main.menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it "computes the correct percentages" do # rubocop:disable RSpec/ExampleLength
      expect(data).to eq([
                           {
                             Académie: "Bordeaux",
                             DA: 0.25,
                             "Coord. bancaires": 0.25,
                             "PFMPs validées": 0.25,
                             "Données élèves": 0.25,
                             "Mt. prêt envoi": 5.0,
                             "Mt. annuel total": 400,
                             Scolarités: 4,
                             "Toutes PFMPs": 4,
                             "Dem. envoyées": 1,
                             "Dem. intégrées": 1,
                             "Dem. payées": 1,
                             "Mt. payé": 5,
                             "Ratio PFMPs payées/payables": 1.0
                           },
                           {
                             Académie: "Montpellier",
                             DA: 0.5,
                             "Coord. bancaires": 0.5,
                             "PFMPs validées": 0.5,
                             "Données élèves": 0.5,
                             "Mt. prêt envoi": 15.0,
                             "Mt. annuel total": 600,
                             Scolarités: 6,
                             "Toutes PFMPs": 6,
                             "Dem. envoyées": 3,
                             "Dem. intégrées": 3,
                             "Dem. payées": 3,
                             "Mt. payé": 15,
                             "Ratio PFMPs payées/payables": 1.0
                           },
                           {
                             Académie: "Paris",
                             DA: 0.4,
                             "Coord. bancaires": 0.4,
                             "PFMPs validées": 0.4,
                             "Données élèves": 0.4,
                             "Mt. prêt envoi": 10.0,
                             "Mt. annuel total": 500,
                             Scolarités: 5,
                             "Toutes PFMPs": 5,
                             "Dem. envoyées": 2,
                             "Dem. intégrées": 2,
                             "Dem. payées": 2,
                             "Mt. payé": 10,
                             "Ratio PFMPs payées/payables": 1.0
                           }
                         ])
    end
  end

  describe "#establishments_data" do
    subject(:data) { main.establishments_data }

    include_context "when there is data for stats per establishments"

    it "computes the correct percentages" do # rubocop:disable RSpec/ExampleLength
      expect(data).to eq([
                           {
                             UAI: "0000000A",
                             "Nom de l'établissement": "0000000A",
                             Ministère: "MINISTERE DE L'EDUCATION NATIONALE",
                             Académie: "Marseille",
                             "Privé/Public": "Public",
                             DA: 0.25,
                             "Coord. bancaires": 0.25,
                             "PFMPs validées": 0.25,
                             "Données élèves": 0.25,
                             "Mt. prêt envoi": 5.0,
                             "Mt. annuel total": 400,
                             Scolarités: 4,
                             "Toutes PFMPs": 4,
                             "Dem. envoyées": 1,
                             "Dem. intégrées": 1,
                             "Dem. payées": 1,
                             "Mt. payé": 5,
                             "Ratio PFMPs payées/payables": 1.0
                           },
                           {
                             UAI: "0000000B",
                             "Nom de l'établissement": "0000000B",
                             Ministère: "MINISTERE DE L'EDUCATION NATIONALE",
                             Académie: "Marseille",
                             "Privé/Public": "Public",
                             DA: 0.5,
                             "Coord. bancaires": 0.5,
                             "PFMPs validées": 0.5,
                             "Données élèves": 0.5,
                             "Mt. prêt envoi": 15.0,
                             "Mt. annuel total": 600,
                             Scolarités: 6,
                             "Toutes PFMPs": 6,
                             "Dem. envoyées": 3,
                             "Dem. intégrées": 3,
                             "Dem. payées": 3,
                             "Mt. payé": 15,
                             "Ratio PFMPs payées/payables": 1.0
                           },
                           {
                             UAI: "0000000C",
                             "Nom de l'établissement": "0000000C",
                             Ministère: "MINISTERE DE L'EDUCATION NATIONALE",
                             Académie: "Marseille",
                             "Privé/Public": "Public",
                             DA: 0.4,
                             "Coord. bancaires": 0.4,
                             "PFMPs validées": 0.4,
                             "Données élèves": 0.4,
                             "Mt. prêt envoi": 10.0,
                             "Mt. annuel total": 500,
                             Scolarités: 5,
                             "Toutes PFMPs": 5,
                             "Dem. envoyées": 2,
                             "Dem. intégrées": 2,
                             "Dem. payées": 2,
                             "Mt. payé": 10,
                             "Ratio PFMPs payées/payables": 1.0
                           }
                         ])
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
