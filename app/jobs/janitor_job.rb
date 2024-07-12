# frozen_string_literal: true

class JanitorJob < ApplicationJob
  sidekiq_options retry: false

  def perform
    reset_attributive_decision_version_overflow
  end

  private

  def reset_attributive_decision_version_overflow
    Schooling.where("attributive_decision_version > ?", 9).find_each do |schooling|
      schooling.update!(attributive_decision_version: 9)
    end
    true
  end
end
