# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Sum::Yearly do
  describe "#global_data" do
    subject { described_class.new(SchoolYear.current.start_year).global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 500 }
  end

  describe "#bops_data" do
    subject { described_class.new(SchoolYear.current.start_year).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 400, "ENPR" => 500, "MASA" => 500, "MER" => 700, "ARMEE" => 600 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(SchoolYear.current.start_year).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 400, "Montpellier" => 600, "Paris" => 500 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(SchoolYear.current.start_year).establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "0000000A" => 400, "0000000B" => 600, "0000000C" => 500 }) }
  end
end
