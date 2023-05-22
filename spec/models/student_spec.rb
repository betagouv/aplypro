# frozen_string_literal: true

require "rails_helper"

RSpec.describe Student, type: :model do
  it "has a valid factory" do
    expect(build(:student)).to be_valid
  end

  it { is_expected.to belong_to(:classe) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:ine) }
end
