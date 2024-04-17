# frozen_string_literal: true

require "attribute_decision_generator"

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

    io = StringIO.new

    AttributeDecisionGenerator.new(schooling).generate!(io)

    io.rewind

    schooling.rattach_attributive_decision!(io)
  end
end
