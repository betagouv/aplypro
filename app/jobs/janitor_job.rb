# frozen_string_literal: true

class JanitorJob < ApplicationJob
  sidekiq_options retry: false

  def perform
    reset_attributive_decision_version_attribute
    reset_generating_attributive_decision_attribute
  end

  private

  def reset_attributive_decision_version_attribute
    Schooling.where("attributive_decision_version > ?", 9).find_each do |schooling|
      schooling.update!(attributive_decision_version: 9)
    end
    true
  end

  def reset_generating_attributive_decision_attribute
    Schooling.generating_attributive_decision.each do |schooling|
      schooling.update(generating_attributive_decision: false)
    end
  end

  def squish_codes_above_five
    %i[address_city_insee_code address_postal_code].each do |code|
      Student.where("LENGTH(#{code}) > 5").find_each do |s|
        s.update!(code => s.public_send(code).squish)
      end
    end
  end
end
