# frozen_string_literal: true

require "generator/attributor"

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
        schooling.remove!
        schooling.save!
      end
    end

    private

    def generate_document(schooling)
      io = Generator::Cancellation.new(schooling).write
      ASP::AttachDocument.from_schooling(io, schooling, :cancellation_decision)
    end

    def rectify_pfmp_if_necessary(schooling)
      schooling.pfmps.each do |pfmp|
        next unless pfmp.paid?

        PfmpManager.new(pfmp).rectify_and_update_attributes!({ day_count: 0 }, address_params(schooling))
        pfmp.latest_payment_request.mark_ready!
      end
    end

    def address_params(schooling)
      schooling.student.attributes.slice(:address_line1,
                                         :address_line2,
                                         :address_postal_code,
                                         :address_city,
                                         :address_city_insee_code,
                                         :address_country_code)
    end
  end
end
