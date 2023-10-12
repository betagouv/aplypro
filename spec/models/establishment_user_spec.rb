# frozen_string_literal: true

require "rails_helper"

RSpec.describe EstablishmentUser do
  subject(:function) { build(:establishment_user) }

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:user).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
  end
end
