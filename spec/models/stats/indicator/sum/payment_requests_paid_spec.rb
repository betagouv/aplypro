# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Sum::PaymentRequestsPaid do
  describe "#menj_academies_data" do
    subject { described_class.new(SchoolYear.current.start_year).menj_academies_data }

    include_context "when there is data for stats per MENJ academies"

    it { is_expected.to eq({ "Bordeaux" => 1 * 5, "Montpellier" => 3 * 5, "Paris" => 2 * 5 }) }
  end
end
