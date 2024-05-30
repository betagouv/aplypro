# frozen_string_literal: true

class AttributiveDecisionHelpers
  def self.generate_fake_attributive_decision(schooling)
    schooling.tap(&:generate_administrative_number).save!
    schooling.attach_attributive_document(StringIO.new("hello"), :attributive_decision)
  end

  def self.generate_fake_abrogation_decision(schooling)
    schooling.attach_attributive_document(StringIO.new("hello"), :abrogation_decision)
  end
end
