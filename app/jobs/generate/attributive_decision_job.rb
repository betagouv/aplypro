# frozen_string_literal: true

require "attribute_decision/attributor"

module Generate
  class AttributiveDecisionJob < ApplicationJob
    include DocumentGeneration
    include FregataProof

    after_discard do |job|
      self.class.after_discard_callback(job, :generating_attributive_decision)
    end

    around_perform do |job, block|
      self.class.around_perform_callback(job, :generating_attributive_decision, &block)
    end

    def perform(schooling)
      sync_data(schooling)

      Schooling.transaction do
        generate_document(schooling)
        schooling.save!
      end
    end

    private

    def generate_document(schooling)
      schooling.generate_administrative_number
      schooling.increment(:attributive_decision_version)
      io = AttributeDecision::Attributor.new(schooling).write
      schooling.attach_attributive_document(io, :attributive_decision)
    end

    def sync_data(schooling)
      Sync::StudentJob.new.perform(schooling)
    end
  end
end
