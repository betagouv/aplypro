# frozen_string_literal: true

require "attribute_decision/attributor"

class GenerateAttributiveDecisionJob < ApplicationJob
  queue_as :documents

  sidekiq_options retry: false

  after_discard do |job|
    schooling = job.arguments.first

    schooling.update!(generating_attributive_decision: false)
  end

  retry_on Faraday::UnauthorizedError, wait: 1.second, attempts: 5

  around_perform do |job, block|
    schooling = job.arguments.first

    schooling.update!(generating_attributive_decision: true)

    block.call

    schooling.update!(generating_attributive_decision: false)
  end

  def perform(schooling)
    FetchStudentInformationJob.new.perform(schooling) if schooling.student.missing_address?

    Schooling.transaction do
      schooling.generate_administrative_number
      schooling.increment(:attributive_decision_version)
      io = AttributeDecision::Attributor.new(schooling).write
      schooling.attach_attributive_document(io, :attributive_decision)
      schooling.save!
    end
  end
end
