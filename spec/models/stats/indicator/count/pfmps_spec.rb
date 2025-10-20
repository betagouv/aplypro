# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Count::Pfmps do
  describe "#global_data" do
    subject { described_class.new(SchoolYear.current.start_year).global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 5 }
  end

  describe "#bops_data" do
    subject { described_class.new(SchoolYear.current.start_year).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 4, "ENPR" => 5, "MASA" => 5, "MER" => 7, "ARMEE" => 6 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(SchoolYear.current.start_year).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 4, "Montpellier" => 6, "Paris" => 5 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(SchoolYear.current.start_year).establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "0000000A" => 4, "0000000B" => 6, "0000000C" => 5 }) }
  end
end
