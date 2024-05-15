# frozen_string_literal: true

class AttributiveDecisionHelpers
  def self.generate_fake_attributive_decision(schooling)
    schooling.tap(&:generate_administrative_number).save!
    schooling.rattach_attributive_decision!(StringIO.new("hello"))
  end
end
