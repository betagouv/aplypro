# frozen_string_literal: true

class AttributiveDecisionHelpers
  def self.generate_fake_attributive_decision(schooling)
    schooling.tap(&:generate_administrative_number).save!
    ASP::AttachDocument.from_schooling(StringIO.new("hello"), schooling, :attributive_decision)
  end

  def self.generate_fake_abrogation_decision(schooling)
    ASP::AttachDocument.from_schooling(StringIO.new("hello"), schooling, :abrogation_decision)
  end

  def self.generate_fake_cancellation_decision(schooling)
    ASP::AttachDocument.from_schooling(StringIO.new("hello"), schooling, :cancellation_decision)
  end
end
