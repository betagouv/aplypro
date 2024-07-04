require 'rails_helper'

RSpec.describe JanitorJob do

  describe '#reset_attributive_decision_version_overflow' do
    let!(:schooling_under_9) { create(:schooling, attributive_decision_version: 8) }
    let!(:schooling_equal_9) { create(:schooling, attributive_decision_version: 9) }
    let!(:schooling_above_9) { create(:schooling, attributive_decision_version: 10) }

    before do
      described_class.new.send(:reset_attributive_decision_version_overflow)
    end

    it 'does not change the attributive_decision_version of schoolings under 9' do
      expect(schooling_under_9.reload.attributive_decision_version).to eq(8)
    end

    it 'does not change the attributive_decision_version of schoolings equal to 9' do
      expect(schooling_equal_9.reload.attributive_decision_version).to eq(9)
    end

    it 'resets the attributive_decision_version of schoolings above 9 to 9' do
      expect(schooling_above_9.reload.attributive_decision_version).to eq(9)
    end
  end
end
# frozen_string_literal: true