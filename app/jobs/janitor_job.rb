# frozen_string_literal: true

require "rails_helper"

class JanitorJob < ApplicationJob
  def perform
    reset_attributive_decision_version_overflow
  end

  private

  def reset_attributive_decision_version_overflow
    Schooling.where("attributive_decision_version > ?", 9).find_each do |schooling|
      schooling.update(attributive_decision_version: 9)
    end
  end
end
