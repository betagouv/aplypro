# frozen_string_literal: true

require "attribute_decision/attributor"

module Generate
  class CancellationDecisionJob < ApplicationJob
    include DocumentGeneration

    class MissingAttributiveDecisionError < StandardError
    end

    after_discard do |job|
      self.class.after_discard_callback(job, :generating_attributive_decision)
    end

    around_perform do |job, block|
      self.class.around_perform_callback(job, :generating_attributive_decision, &block)
    end

    def perform(schooling)
      raise MissingAttributiveDecisionError if schooling.attributive_decision.blank?

      Sync::StudentJob.new.perform(schooling)

      Schooling.transaction do
        generate_document(schooling)
        rectify_pfmp_if_necessary(schooling)
        schooling.hidden!
        schooling.save!
      end
    end

    private

    def generate_document(schooling)
      io = AttributeDecision::Cancellation.new(schooling).write
      schooling.attach_attributive_document(io, :cancellation_decision)
    end

    def rectify_pfmp_if_necessary(schooling)
      schooling.pfmps.each do |pfmp|
        next unless pfmp.paid?

        PfmpManager.new(pfmp).rectify_and_update_attributes!({ day_count: 0 }, address_params)
      end
    end

    def address_params
      schooling.student.attributes.slice(:address_line1,
                                         :address_line2,
                                         :address_postal_code,
                                         :address_city,
                                         :address_city_insee_code,
                                         :address_country_code)
    end
  end
end
