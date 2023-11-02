# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe Establishment do
  subject(:etab) { build(:establishment, :with_fim_user) }

  it { is_expected.to validate_presence_of(:uai) }
  it { is_expected.to validate_uniqueness_of(:uai) }
end
