# frozen_string_literal: true

class AttributiveDecisionHelpers
  def self.generate_fake_attributive_decision(schooling)
    schooling.tap(&:generate_administrative_number).save!
    schooling.attach_attributive_document(StringIO.new("hello"), :attributive_decision)
  end
end
