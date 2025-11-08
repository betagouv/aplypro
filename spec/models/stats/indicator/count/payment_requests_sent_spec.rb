# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Count::PaymentRequestsSent do
  describe "#global_data" do
    subject { described_class.new(SchoolYear.current.start_year).global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 2 }
  end

  describe "#bops_data" do
    subject { described_class.new(SchoolYear.current.start_year).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 1, "ENPR" => 4, "MASA" => 2, "MER" => 4, "ARMEE" => 3 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(SchoolYear.current.start_year).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1, "Montpellier" => 3, "Paris" => 2 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(SchoolYear.current.start_year).establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "0000000A" => 1, "0000000B" => 3, "0000000C" => 2 }) }
  end
end
