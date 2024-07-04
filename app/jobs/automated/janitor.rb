# frozen_string_literal: true

class JanitorJob < ApplicationJob

  def perform
    reset_attributive_decision_version_overflow
  end

  private
  def reset_attributive_decision_version_overflow
    Schooling.where('attributive_decision_version > ?', 9).update_all(attributive_decision_version: 9)
  end

end