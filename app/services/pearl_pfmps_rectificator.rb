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

    Rails.logger.info "Schooling #{schooling.id} has excess of #{excess_amount} (paid: #{total_paid}, cap: #{yearly_cap})"

    distribute_rectifications(schooling, excess_amount)
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
             .sum { |pfmp| extract_real_amount(pfmp).to_i }
  end

  def distribute_rectifications(schooling, excess_amount) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    eligible_pfmps = schooling.pfmps
                              .in_state(:validated)
                              .select(&:paid?)
                              .select { |p| p.amount.to_i.positive? }
                              .sort_by { |p| -p.amount.to_i }

    remaining_excess = excess_amount
    rectified_count = 0
    address_params = schooling.student.attributes.slice("address_line1")

    eligible_pfmps.each do |pfmp|
      break if remaining_excess <= 0

      paid_amount = extract_real_amount(pfmp).to_i
      max_reduction = [paid_amount, remaining_excess].min

      next if max_reduction <= 5

      new_amount = paid_amount - max_reduction
      Rails.logger.info "Rectifying PFMP #{pfmp.id}: reducing from #{paid_amount} to #{new_amount}"

      pfmp.skip_amounts_yearly_cap_validation = true
      pfmp.update!(amount: new_amount)

      PfmpManager.new(pfmp).rectify_and_update_attributes!(
        { day_count: pfmp.day_count },
        address_params
      )

      remaining_excess -= max_reduction
      rectified_count += 1
    end

    if remaining_excess.positive?
      Rails.logger.warn "Could not distribute entire excess for schooling #{schooling.id}. Remaining: #{remaining_excess}"
    end

    Rails.logger.info "Rectified #{rectified_count} PFMPs for schooling #{schooling.id}"
    results[:rectified] << schooling.id
  end
end
