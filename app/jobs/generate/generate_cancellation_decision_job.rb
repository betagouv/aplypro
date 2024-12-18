# frozen_string_literal: true

require "attribute_decision/attributor"

class GenerateCancellationDecisionJob < ApplicationJob
  include DocumentGeneration

  class MissingAttributiveDecisionError < StandardError
  end

  class MissingSchoolingEndDateError < StandardError
  end

  after_discard do |job|
    self.class.after_discard_callback(job, :generating_attributive_decision)
  end

  around_perform do |job, block|
    self.class.around_perform_callback(job, :generating_attributive_decision, &block)
  end

  def perform(schooling)
    raise MissingAttributiveDecisionError if schooling.attributive_decision.blank?
    raise MissingSchoolingEndDateError if schooling.open?

    Schooling.transaction do
      generate_document(schooling)
      schooling.save!
    end
  end

  private

  def generate_document(schooling)
    # schooling.increment(:abrogation_decision_version)
    io = AttributeDecision::Cancellation.new(schooling).write
    schooling.attach_attributive_document(io, :cancellation_decision)
  end
end
