# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::ValidatedPfmps do
  describe "#global_data" do
    subject { described_class.new.global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 0.4 }
  end

  describe "#bops_data" do
    subject { described_class.new.bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 0.25, "ENPR" => 0.8, "MASA" => 0.4, "MER" => 4.0 / 7, "ARMEE" => 0.5 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new.menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 0.25, "Montpellier" => 0.5, "Paris" => 0.4 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new.establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "etab1" => 0.25, "etab2" => 0.5, "etab3" => 0.4 }) }
  end
end
