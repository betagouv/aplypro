# frozen_string_literal: true

class PearlPfmpsRectificator < MassRectificator
  private

  def rectify_pfmp(schooling, target_pfmp)
    sync_student_data(schooling)
    validate_student_address(schooling)

    total_paid = calculate_total_paid(schooling)
    yearly_cap = target_pfmp.mef.wage.yearly_cap
    excess_amount = total_paid - yearly_cap

    if excess_amount <= PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      skip_schooling(schooling, "no excess amount to rectify")
      return
    end

    Rails.logger.info "Schooling #{schooling.id} has excess of #{excess_amount} " \
                      "(paid: #{total_paid}, cap: #{yearly_cap})"

    ApplicationRecord.transaction do
      distribute_rectifications(schooling, excess_amount)
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

  def distribute_rectifications(schooling, _excess_amount) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    rectified_count = 0
    address_params = schooling.student.attributes.slice("address_line1")

    loop do
      schooling.reload
      current_total = calculate_total_paid(schooling)
      yearly_cap = schooling.pfmps.first.mef.wage.yearly_cap
      current_excess = current_total - yearly_cap

      break if current_excess <= PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD

      eligible_pfmps = schooling.pfmps
                                .in_state(:validated)
                                .select(&:paid?)
                                .sort_by { |p| -p.amount.to_i }

      break if eligible_pfmps.empty?

      pfmp = eligible_pfmps.first
      paid_amount = pfmp.paid_amount

      if current_excess >= paid_amount
        new_amount = 0
        max_reduction = paid_amount
      else
        max_reduction = current_excess
        new_amount = paid_amount - max_reduction
      end

      break if max_reduction <= PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD

      Rails.logger.info "Rectifying PFMP #{pfmp.id}: reducing from #{paid_amount} to #{new_amount}"

      pfmp.skip_amounts_yearly_cap_validation = true

      PfmpManager.new(pfmp).rectify_and_update_attributes!(
        { amount: new_amount },
        address_params
      )

      rectified_count += 1
    end

    final_total = calculate_total_paid(schooling)
    final_excess = final_total - schooling.pfmps.first.mef.wage.yearly_cap
    if final_excess > PfmpManager::EXCESS_AMOUNT_RECTIFICATION_THRESHOLD
      Rails.logger.warn "Could not distribute entire excess for schooling #{schooling.id}." \
                        "Remaining: #{final_excess}"
    end

    Rails.logger.info "Rectified #{rectified_count} PFMPs for schooling #{schooling.id}"
    results[:rectified] << schooling.id
  end
end
