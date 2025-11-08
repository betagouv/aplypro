# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

describe Stats::Indicator::Count::PaymentRequestsIntegrated do
  describe "#bops_data" do
    subject { described_class.new(SchoolYear.current.start_year).bops_data }

    include_context "when there is data for stats per bops"

    it { is_expected.to eq({ "ENPU" => 1, "ENPR" => 4, "MASA" => 2, "MER" => 4, "ARMEE" => 3 }) }
  end
end
