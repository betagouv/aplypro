# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::PaymentRequestStates do
  describe "#global_data" do
    subject { described_class.new(:sent).global_data }

    include_context "when there is data for global stats"

    it { is_expected.to eq 2 }
  end

  describe "#bops_data" do
    subject { described_class.new(:integrated).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 1, "ENPR" => 4, "MASA" => 2, "MER" => 4, "ARMEE" => 3 }) }
  end

  describe "#menj_academies_data" do
    subject { described_class.new(:paid).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1, "Montpellier" => 3, "Paris" => 2 }) }
  end

  describe "#establishments_data" do
    subject { described_class.new(:sent).establishments_data }

    include_context "when there is data for stats per establishments"

    it { is_expected.to eq({ "etab1" => 1, "etab2" => 3, "etab3" => 2 }) }
  end
end
