# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Schoolings do
  describe "#global_data" do
    subject { described_class.new.global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 5 }
  end

  describe "#bops_data" do
    subject { described_class.new.bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 4, "ENPR" => 5, "MASA" => 5, "MER" => 7, "ARMEE" => 6 }) }
  end

  describe "#menj_academies_data", skip: "flaky, violates unique constraint 'index_schoolings_on_asp_dossier_id'" do
    subject { described_class.new.menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 4, "Montpellier" => 6, "Paris" => 5 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new.establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "etab1" => 4, "etab2" => 6, "etab3" => 5 }) }
  end
end
