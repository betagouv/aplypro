# frozen_string_literal: true

class MassRectificator # rubocop:disable Metrics/ClassLength
  class RectificationError < StandardError; end
  class NegativeAmountError < RectificationError; end

  attr_reader :schooling_ids, :results

  def initialize(schooling_ids)
    @schooling_ids = schooling_ids
    @results = {
      processed: 0,
      rectified: [],
      skipped: [],
      errors: [],
      pearl_pfmps: []
    }
  end

  def call
    Rails.logger.info "Processing batch of #{schooling_ids.count} schoolings"

    ApplicationRecord.transaction do
      Schooling.where(id: schooling_ids).find_each do |schooling|
        process_schooling(schooling)
      end
    end

    log_results
    results
  end

  private

  def process_schooling(schooling)
    Rails.logger.info "Processing schooling #{schooling.id}"
    results[:processed] += 1

    if already_rectified?(schooling)
      skip_schooling(schooling, "already has rectified PFMPs")
      return
    end

    target_pfmp = find_target_pfmp(schooling)
    unless target_pfmp
      skip_schooling(schooling, "no valid target PFMP found")
      return
    end

    if payment_request_ready?(target_pfmp)
      skip_schooling(schooling, "payment request in ready state")
      return
    end

    rectify_pfmp(schooling, target_pfmp)
  rescue StandardError => e
    handle_error(schooling, e)
  end

  def already_rectified?(schooling)
    schooling.pfmps.any?(&:rectified?)
  end

  def find_target_pfmp(schooling)
    schooling.pfmps
             .in_state(:validated)
             .select(&:paid?)
             .max_by(&:amount)
  end

  def payment_request_ready?(pfmp)
    pfmp.latest_payment_request&.current_state == "ready"
  end

  def rectify_pfmp(schooling, target_pfmp) # rubocop:disable Metrics/AbcSize
    reset_pfmp_amounts(schooling)
    sync_student_data(schooling)
    validate_student_address(schooling)

    address_params = target_pfmp.student.attributes.slice("address_line1")

    Rails.logger.info "Attempting rectification of Schooling #{schooling.id} on PFMP #{target_pfmp.id}"

    PfmpManager.new(target_pfmp).rectify_and_update_attributes!(
      { day_count: target_pfmp.day_count },
      address_params
    )

    results[:rectified] << schooling.id
    Rails.logger.info "Successfully rectified schooling #{schooling.id}"
  rescue PfmpManager::RectificationAmountThresholdNotReachedError,
         PfmpManager::RectificationAmountZeroError
    skip_schooling(schooling, "amount too small or zero")
  rescue ActiveRecord::RecordInvalid => e
    raise unless e.message.include?("Amount doit être supérieur ou égal à 0")

    results[:pearl_pfmps] << target_pfmp.id
    raise NegativeAmountError, "PFMP #{target_pfmp.id} has negative amount"
  end

  def reset_pfmp_amounts(schooling)
    schooling.pfmps.each do |pfmp|
      next unless should_reset_amount?(pfmp)

      real_amount = extract_real_amount(pfmp)
      next if pfmp.amount == real_amount.to_i

      pfmp.update(amount: real_amount.to_i)
      Rails.logger.info "Reset amount to #{real_amount} for PFMP #{pfmp.id}"
    end
  end

  def should_reset_amount?(pfmp)
    pfmp.latest_payment_request.present? &&
      pfmp.latest_payment_request.current_state == "paid"
  end

  def extract_real_amount(pfmp)
    pfmp.latest_payment_request
        .last_transition
        .metadata.dig("PAIEMENT", "MTNET")
        .to_f
  end

  def sync_student_data(schooling)
    Rails.logger.info "Syncing student data for schooling #{schooling.id}"

    retry_count = 0
    begin
      Sync::StudentJob.new.perform(schooling)
    rescue Faraday::UnauthorizedError
      retry_count += 1
      Rails.logger.warn "Auth error syncing schooling #{schooling.id}, retry #{retry_count}"
      sleep(1)
      retry if retry_count < 5
      raise
    end
  end

  def validate_student_address(schooling)
    student = schooling.student

    unless (student.address_line1.present? || student.address_line2.present?) &&
           student.address_country_code.present? &&
           student.address_postal_code.present? &&
           student.address_city_insee_code.present?
      raise RectificationError, "Missing address attributes for schooling #{schooling.id}"
    end
  end

  def skip_schooling(schooling, reason)
    results[:skipped] << { id: schooling.id, reason: reason }
    Rails.logger.info "Skipping schooling #{schooling.id}: #{reason}"
  end

  def handle_error(schooling, error)
    results[:errors] << { id: schooling.id, error: error.message }
    Rails.logger.error "Error processing schooling #{schooling.id}: #{error.message}"
    Rails.logger.error error.backtrace.join("\n") if Rails.env.development?
  end

  def log_results # rubocop:disable Metrics/AbcSize
    Rails.logger.info <<~LOG
      Mass correction completed:
      - Processed: #{results[:processed]}
      - Rectified: #{results[:rectified].count}
      - Skipped: #{results[:skipped].count}
      - Errors: #{results[:errors].count}
      - Pearl PFMPs: #{results[:pearl_pfmps].count}
    LOG

    return unless results[:pearl_pfmps].any?

    Rails.logger.warn "PFMPs with negative amounts: #{results[:pearl_pfmps].join(', ')}"
  end
end
