require 'rails_helper'
require "csv"

RSpec.describe Mefstat, type: :model do
  subject(:mefstat) { build(:mefstat) }

  it { is_expected.to validate_presence_of(:label) }
  it { is_expected.to validate_presence_of(:short) }
end
