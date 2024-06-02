# frozen_string_literal: true

require "abrogation/generator"

class GenerateAbrogationDecisionJob < ApplicationJob
  include DocumentGeneration

  after_discard do |job|
    self.class.after_discard_callback(job, :generating_abrogation)
  end

  around_perform do |job, block|
    self.class.around_perform_callback(job, :generating_abrogation, &block)
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
