# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schooling do
  describe "associations" do
    it { is_expected.to belong_to(:student).class_name("Student") }
    it { is_expected.to belong_to(:classe).class_name("Classe") }
    it { is_expected.to have_many(:pfmps).class_name("Pfmp") }
    it { is_expected.to have_one(:mef).class_name("Mef") }
  end

  describe "generate_attributive_decision" do
    let(:schooling) { create(:schooling) }

    it "generates and attaches an attributive decision" do
      expect { schooling.generate_attributive_decision }.to change { schooling.attributive_decision.attached? }.to true
    end
  end
end
