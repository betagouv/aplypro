# frozen_string_literal: true

require "attribute_decision_generator"

class GenerateAttributiveDecisionJob < ApplicationJob
  def perform(schooling)
    FetchStudentAddressJob.perform_now(schooling.student) if schooling.student.missing_address?

    io = StringIO.new

    AttributeDecisionGenerator.new(schooling).generate!(io)

    io.rewind

    schooling.rattach_attributive_decision!(io)
  end
end
