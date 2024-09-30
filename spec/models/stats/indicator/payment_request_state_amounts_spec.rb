# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::PaymentRequestStateAmounts do
  describe "#global_data" do
    subject { described_class.new(:sent).global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 2 * 5 }
  end

  describe "#bops_data" do
    subject { described_class.new(:integrated).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 1 * 5, "ENPR" => 4 * 5, "MASA" => 2 * 5, "MER" => 4 * 5, "ARMEE" => 3 * 5 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(:paid).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1 * 5, "Montpellier" => 3 * 5, "Paris" => 2 * 5 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(:sent).establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "0000000A" => 1 * 5, "0000000B" => 3 * 5, "0000000C" => 2 * 5 }) }
  end
end
