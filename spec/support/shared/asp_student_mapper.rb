# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "an ASP payment mapping entity" do
  it "produces a valid object" do
    expect(described_class.from_payment(payment)).to be_valid
  end
end
