# frozen_string_literal: true

require "rails_helper"

RSpec.describe Classe do
  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:mef).class_name("Mef") }
    it { is_expected.to have_many(:students).order("last_name") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:start_year) }
    it { is_expected.to validate_numericality_of(:start_year).only_integer.is_greater_than_or_equal_to(2023) }
  end
end
