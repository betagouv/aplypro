# frozen_string_literal: true

require "rails_helper"

RSpec.describe Student do
  it "has a valid factory" do
    expect(build(:student)).to be_valid
  end

  it { is_expected.to have_many(:classes).through(:schoolings) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:birthdate) }
  it { is_expected.to validate_presence_of(:ine) }
end
