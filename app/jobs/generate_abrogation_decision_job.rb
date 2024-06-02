# frozen_string_literal: true

require "attribute_decision/attributor"

class GenerateAbrogationDecisionJob < ApplicationJob
  include DocumentGeneration

  after_discard do |job|
    self.class.after_discard_callback(job, :generating_attributive_decision)
  end

  around_perform do |job, block|
    self.class.around_perform_callback(job, :generating_attributive_decision, &block)
  end

  def perform(schooling)
    Schooling.transaction do
      generate_document(schooling)
      schooling.save!
    end
  end

  private

  def generate_document(schooling)
    io = AttributeDecision::Abrogator.new(schooling).write
    schooling.attach_attributive_document(io, :abrogation_decision)
  end
end
