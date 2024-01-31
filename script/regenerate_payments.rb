# frozen_string_literal: true

# ----------------------------------------
# rubocop:disable Metrics/AbcSize
# For a given MEF, this method corrects all payments in a list of pfmps
# Note : It is possible for a student who went through different MEFs to reach each MEF's yearly_cap independently
#        I remember that it is supposed to be like this from a conversation with the Degesco
def correct_payments_of_a_student_for_a_mef(pfmps, mef)
  yearly_cap = mef.wage.yearly_cap
  daily_rate = mef.wage.daily_rate
  checked_amount = 0

  pfmps.each do |pfmp|
    # delete extra payments that should'nt even exist
    pfmp.payments.drop(1).each(&:destroy) if pfmps.payments.size > 1

    allowance_left = yearly_cap - checked_amount
    payment = pfmp.payments.first

    computed_amount = [pfmp.day_count * daily_rate, allowance_left].min
    payment.update(amount: computed_amount) if payment.amount != computed_amount
    checked_amount += computed_amount
  end
end

# ----------------------------------------
# Get pfmps grouped by students
all_pfmps_per_student = Pfmp
                        .joins(:schooling)
                        .group(:"schoolings.student_id")
                        .pluck("schoolings.student_id", "array_agg(pfmps.id)")

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

# rubocop:enable Metrics/AbcSize
