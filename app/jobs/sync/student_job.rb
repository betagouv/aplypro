# frozen_string_literal: true

module Sync
  class StudentJob < ApplicationJob
    queue_as :default

    def perform(schooling)
      student = schooling.student

      return true if student.ine_not_found || schooling.closed?

      fetch_student_data(schooling)

      Sync::StudentSchoolingsJob.perform_later(student) if Rails.env.production?
    rescue Faraday::ResourceNotFound
      schooling.student.update!(ine_not_found: true)
    end

    private

    def fetch_student_data(schooling)
      api = schooling.establishment.students_api
      api.fetch_resource(:student, ine: schooling.student.ine)
         .then { |data| map_student_attributes(data, api) }
         .then { |attributes| schooling.student.update!(attributes) }

      retry_rejected_or_unpaid_payment_request!(schooling.student)
    end

    def map_student_attributes(data, api)
      student_attributes = api.student_mapper.new.call(data)
      address_attributes = api.address_mapper.new.call(data)

      student_attributes
        .merge(address_attributes)
        .slice(*Student.updatable_attributes)
        .except(:ine)
    end

    def retry_rejected_or_unpaid_payment_request!(student)
      if student.previous_changes.key?("address_line1") ||
         student.previous_changes.key?("address_line2") ||
         student.previous_changes.key?("address_city_insee_code") ||
         student.previous_changes.key?("address_country_code")

        student.pfmps.in_state(:validated).each do |pfmp|
          if pfmp.latest_payment_request&.eligible_for_rejected_or_unpaid_auto_retry?(%w[ADRESSE PAYS])
            p_r = PfmpManager.new(pfmp).create_new_payment_request!
            p_r.mark_ready!
          end
        end
      end
    end
  end
end
