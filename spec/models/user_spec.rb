# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment").optional }
  end

  describe "validations" do
    %w[uid name email provider token secret email].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end
end
