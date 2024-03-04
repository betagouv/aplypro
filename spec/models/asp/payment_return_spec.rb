# frozen_string_literal: true

require "rails_helper"

describe ASP::PaymentReturn do
  subject(:model) { described_class.new(filename: "foobar") }

  it { is_expected.to validate_presence_of(:filename) }
  it { is_expected.to validate_uniqueness_of(:filename) }
end
