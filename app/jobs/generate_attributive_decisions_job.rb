# frozen_string_literal: true

require "attribute_decision_generator"

class GenerateAttributiveDecisionsJob < ApplicationJob
  queue_as :default

  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(generating_attributive_decisions: true)

    block.call

    establishment.update!(generating_attributive_decisions: false)
  end

  def perform(establishment)
    establishment.classes.current.includes(:schoolings).find_each do |classe|
      classe.schoolings.each do |schooling|
        Tempfile.create("da") do |file|
          AttributeDecisionGenerator.new(schooling.student).generate!(file)

          file.rewind

          schooling.rattach_attributive_decision!(file)
        end
      end
    end
  end
end
