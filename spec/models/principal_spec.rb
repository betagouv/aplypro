# frozen_string_literal: true

require "rails_helper"

RSpec.describe Principal do
  it "has a valid factory" do
    expect(build(:principal)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
  end

  describe "validations" do
    %w[uid name email provider token secret email].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end
end
