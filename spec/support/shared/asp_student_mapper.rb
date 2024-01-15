# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "an ASP student mapping entity" do
  it "produces a valid object" do
    expect(described_class.from_student(student)).to be_valid
  end
end
