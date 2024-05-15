# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Stats::Main do
  let(:indicators_titles) { described_class.new.indicators_titles }

  describe "#global_data" do
    subject(:data) { described_class.new.global_data }

    include_context "when there is data for global stats"

    it "computes the right percentages" do
      expect(data).to eq(
        [indicators_titles,
         [0.4, 0.4, 0.4, 0.4, 10.0, 500, 5, 5, 2, 0, 0, 0]]
      )
    end
  end

  describe "#bops_data" do
    subject(:data) { described_class.new.bops_data }

    include_context "when there is data for stats per bops"

    # rubocop:disable RSpec/ExampleLength
    it "computes the correct percentages" do
      expect(data).to eq(
        [["BOP", *indicators_titles],
         ["ENPU", 0.25, 0.25, 0.25, 0.25, 5.0, 400, 4, 4, 1, 1, nil, nil],
         ["ENPR", 0.8, 0.8, 0.8, 0.8, 20.0, 500, 5, 5, 4, 4, nil, nil],
         ["MASA", 0.4, 0.4, 0.4, 0.4, 10.0, 500, 5, 5, 2, 2, nil, nil],
         ["MER", 4.0 / 7, 4.0 / 7, 4.0 / 7, 4.0 / 7, 20.0, 700, 7, 7, 4, 4, nil, nil],
         ["ARMEE", 0.5, 0.5, 0.5, 0.5, 15.0, 600, 6, 6, 3, 3, nil, nil]]
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#menj_academies_data" do
    subject(:data) { described_class.new.menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    # rubocop:disable RSpec/ExampleLength
    it "computes the correct percentages" do
      expect(data).to eq(
        [["Académie", *indicators_titles],
         ["Bordeaux", 0.25, 0.25, 0.25, 0.25, 5.0, 400, 4, 4, 1, 1, 1, 5],
         ["Montpellier", 0.5, 0.5, 0.5, 0.5, 15.0, 600, 6, 6, 3, 3, 3, 15],
         ["Paris", 0.4, 0.4, 0.4, 0.4, 10.0, 500, 5, 5, 2, 2, 2, 10]]
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "#establishments_data" do
    subject(:data) { described_class.new.establishments_data }

    include_context "when there is data for stats per establishments"

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable Layout/LineLength
    it "computes the correct percentages" do
      expect(data).to eq(
        [["UAI", "Nom de l'établissement", "Ministère", "Académie", "Privé/Public", *indicators_titles],
         ["etab1", "etab1", "MINISTERE DE L'EDUCATION NATIONALE", "Marseille", "Public", 0.25, 0.25, 0.25, 0.25, 5.0, 400, 4, 4, 1, 1, 1, 5],
         ["etab2", "etab2", "MINISTERE DE L'EDUCATION NATIONALE", "Marseille", "Public", 0.5, 0.5, 0.5, 0.5, 15.0, 600, 6, 6, 3, 3, 3, 15],
         ["etab3", "etab3", "MINISTERE DE L'EDUCATION NATIONALE", "Marseille", "Public", 0.4, 0.4, 0.4, 0.4, 10.0, 500, 5, 5, 2, 2, 2, 10]]
      )
    end
    # rubocop:enable RSpec/ExampleLength
    # rubocop:enable Layout/LineLength
  end

  describe "#csv_of" do
    subject(:csv_string) { described_class.new.csv_of(data) }

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
