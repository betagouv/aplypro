# frozen_string_literal: true

require "attribute_decision_generator"

class GenerateAttributiveDecisionJob < ApplicationJob
  around_perform do |job, block|
    schooling = job.arguments.first

    schooling.update!(generating_attributive_decision: true)

    block.call

    schooling.update!(generating_attributive_decision: false)
  end

  def perform(schooling)
    FetchStudentAddressJob.perform_now(schooling.student) if schooling.student.missing_address?

    io = StringIO.new

    AttributeDecisionGenerator.new(schooling).generate!(io)

    io.rewind

    schooling.rattach_attributive_decision!(io)
  end
end
