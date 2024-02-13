# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
class PaymentsFixer
  def self.fix_all!
    # Get pfmps grouped by students
    all_pfmps_per_student = Pfmp
                            .joins(:schooling)
                            .group(:"schoolings.student_id")
                            .pluck("schoolings.student_id", "array_agg(pfmps.id)")
                            .to_h

    # Loop over pfmps student by student
    all_pfmps_per_student.each_value do |pfmp_ids|
      # group pfmps of a student by mef
      pfmps_grouped_by_mef = Pfmp.where(id: pfmp_ids)
                                 .includes(:mef)
                                 .group(:"mefs.id")
                                 .pluck("mefs.id", "array_agg(pfmps.id)")

      pfmps_grouped_by_mef.each do |mef_id, pfmp_ids_of_mef|
        pfmps = Pfmp.where(id: pfmp_ids_of_mef).includes(:payments, :mef)
        mef = Mef.find(mef_id)
        correct_payments_of_a_student_for_a_mef(pfmps, mef)
      end
    end
  end

  # For a given MEF, this method corrects all payments in a list of pfmps
  # Note : It is possible for a student who went through different MEFs to reach each MEF's yearly_cap independently
  #        I remember that it is supposed to be like this from a conversation with the Degesco
  def self.correct_payments_of_a_student_for_a_mef(pfmps, mef)
    yearly_cap = mef.wage.yearly_cap
    daily_rate = mef.wage.daily_rate
    checked_amount = 0

    pfmps.each do |pfmp|
      payment, *extra_payments = pfmp.payments

      # delete extra payments that should'nt even exist
      extra_payments.each(&:destroy)

      allowance_left = yearly_cap - checked_amount
      computed_amount = [pfmp.day_count * daily_rate, allowance_left].min

      if computed_amount.zero?
        payment.destroy
      elsif payment.amount != computed_amount
        payment.update(amount: computed_amount)
      end

      checked_amount += computed_amount
    end
  end
end
# rubocop:enable Metrics/AbcSize
