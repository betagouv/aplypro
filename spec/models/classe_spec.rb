# frozen_string_literal: true

require "rails_helper"

RSpec.describe Classe do
  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:mefstat).class_name("Mefstat") }
    it { is_expected.to have_many(:students) }
  end
end
