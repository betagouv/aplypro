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

  def squish_codes_above_five
    %i[address_city_insee_code address_postal_code].each do |code|
      Student.where("LENGTH(#{code}) > 5").find_each do |s|
        s.update!(code => s.public_send(code).squish)
      end
    end
  end
end
