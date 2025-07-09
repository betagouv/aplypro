# frozen_string_literal: true

require "generator/attributor"

module Generate
  class AbrogationDecisionJob < ApplicationJob
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
      schooling.increment(:abrogation_decision_version)
      io = Generator::Abrogator.new(schooling).write
      ASP::AttachDocument.from_schooling(io, schooling, :abrogation_decision)
    end
  end
end
