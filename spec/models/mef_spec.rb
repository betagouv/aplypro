# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Mef do
  subject(:mef) { build(:mef) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:ministry) }
  it { is_expected.to validate_presence_of(:mefstat11) }
  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:short) }
end
