# frozen_string_literal: true

class PearlPfmpsRectificator < MassRectificator # rubocop:disable Metrics/ClassLength
  private

  def rectify_pfmp(schooling, target_pfmp) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    sync_student_data(schooling)
    validate_student_address(schooling)

    log_pfmp_amounts_overview(schooling, "before")

    total_paid = calculate_total_paid(schooling)
    yearly_cap = target_pfmp.mef.wage.yearly_cap
    excess_amount = total_paid - yearly_cap

    if excess_amount <= PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      skip_schooling(schooling, "no excess amount to rectify")
      return
    end

    dry_run_prefix = dry_run ? "[DRY RUN] " : ""
    Rails.logger.info "#{dry_run_prefix}Schooling #{schooling.id} has excess of #{excess_amount} " \
                      "(paid: #{total_paid}, cap: #{yearly_cap})"

    if dry_run
      distribute_rectifications(schooling, excess_amount)
      log_pfmp_amounts_overview(schooling, "after (simulated)")
    else
      ApplicationRecord.transaction do
        distribute_rectifications(schooling, excess_amount)
      end
    end
  rescue StandardError => e
    handle_error(schooling, e)
  end

  def find_target_pfmp(schooling)
    schooling.pfmps
             .in_state(:validated)
             .select(&:paid?)
             .max_by(&:amount)
  end

  def calculate_total_paid(schooling)
    schooling.pfmps
             .select(&:paid?)
             .sum(&:amount)
  end

  def distribute_rectifications(schooling, _excess_amount) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    rectified_count = 0
    address_params = schooling.student.attributes.slice("address_line1")

    loop do
      current_excess = calculate_current_excess(schooling)
      break if current_excess <= PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD

      eligible_pfmps = find_eligible_pfmps_sorted_by_amount(schooling)
      break if eligible_pfmps.empty?

      pfmp = eligible_pfmps.first
      paid_amount = pfmp.paid_amount
      new_amount, max_reduction = calculate_rectification_amounts(current_excess, paid_amount)

      break if max_reduction <= PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD

      if dry_run
        action = "[DRY RUN] Would rectify"
        Rails.logger.info "#{action} PFMP #{pfmp.id}: reducing from #{paid_amount} to #{new_amount}"
      else
        rectify_single_pfmp(pfmp, paid_amount, new_amount, address_params)
      end
      rectified_count += 1
    end

    if dry_run
      log_final_results_dry_run(schooling, rectified_count)
    else
      log_final_results(schooling, rectified_count)
    end
    results[:rectified] << schooling.id
  end

  def calculate_current_excess(schooling)
    schooling.reload
    current_total = calculate_total_paid(schooling)
    yearly_cap = schooling.pfmps.first.mef.wage.yearly_cap
    current_total - yearly_cap
  end

  def find_eligible_pfmps_sorted_by_amount(schooling)
    schooling.pfmps
             .in_state(:validated)
             .select(&:paid?)
             .sort_by { |pfmp| -pfmp.amount.to_i }
  end

  def calculate_rectification_amounts(current_excess, paid_amount)
    if current_excess >= paid_amount
      [0, paid_amount]
    else
      [paid_amount - current_excess, current_excess]
    end
  end

  def rectify_single_pfmp(pfmp, paid_amount, new_amount, address_params)
    Rails.logger.info "Rectifying PFMP #{pfmp.id}: reducing from #{paid_amount} to #{new_amount}"

    pfmp.skip_amounts_yearly_cap_validation = true
    PfmpManager.new(pfmp).rectify_and_update_attributes!(
      { amount: new_amount },
      address_params
    )
  end

  def log_final_results(schooling, rectified_count)
    final_total = calculate_total_paid(schooling)
    final_excess = final_total - schooling.pfmps.first.mef.wage.yearly_cap

    if final_excess > PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      Rails.logger.warn "Could not distribute entire excess for schooling #{schooling.id}. " \
                        "Remaining: #{final_excess}"
    end

    Rails.logger.info "Rectified #{rectified_count} PFMPs for schooling #{schooling.id}"
  end

  def log_final_results_dry_run(schooling, rectified_count)
    current_total = calculate_total_paid(schooling)
    current_excess = current_total - schooling.pfmps.first.mef.wage.yearly_cap

    if current_excess > PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      Rails.logger.warn "[DRY RUN] Could not distribute entire excess for schooling #{schooling.id}. " \
                        "Remaining: #{current_excess}"
    end

    Rails.logger.info "[DRY RUN] Would rectify #{rectified_count} PFMPs for schooling #{schooling.id}"
  end
end
