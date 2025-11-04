# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Ratio::PfmpsPaidPayable do
  describe "#global_data" do
    subject { described_class.new(SchoolYear.current.start_year).global_data }

    include_context "when there is data for payable stats globally"

    it { is_expected.to eq(0.0) }
  end

  describe "#bops_data" do
    subject { described_class.new(SchoolYear.current.start_year).bops_data }

    include_context "when there is data for payable stats per bops"

    it { is_expected.to eq({}) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(SchoolYear.current.start_year).menj_academies_data }

    include_context "when there is data for payable stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1.0, "Montpellier" => 1.0, "Paris" => 1.0 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(SchoolYear.current.start_year).establishments_data }

    include_context "when there is data for payable stats per establishments"

    it { is_expected.to eq({ "0000000A" => 1.0, "0000000B" => 1.0, "0000000C" => 1.0 }) }
  end
end
