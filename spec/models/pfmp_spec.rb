# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pfmp do
  subject(:pfmp) { build(:pfmp) }

  describe "associations" do
    it { is_expected.to belong_to(:student) }
  end
end
