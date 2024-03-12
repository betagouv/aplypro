# frozen_string_literal: true

class PaymentFixer
  def self.call
    new.call
  end

  # denormalise the rates to avoid requerying
  def wages
    @wages ||= Mef.all.to_h do |mef|
      [mef.id, { daily_rate: mef.wage.daily_rate, yearly_cap: mef.wage.yearly_cap }]
    end
  end

  # sorry
  # rubocop:disable Metrics/AbcSize
  def call
    updates = []

    Student
      .distinct
      .joins(:pfmps)
      .merge(Pfmp.not_in_state(:pending))
      .preload(pfmps: :mef)
      .find_each do |student|
      updates << if student.pfmps.one?
                   handle_single_pfmp(student.pfmps.first)
                 else
                   handle_multiple_pfmps(student.pfmps)
                 end
    end

    to_update = updates.flatten.compact.map(&:attributes)

    return if to_update.none?

    Pfmp.upsert_all(to_update, update_only: [:amount]) # rubocop:disable Rails/SkipsModelValidations
  end
  # rubocop:enable Metrics/AbcSize

  def handle_single_pfmp(pfmp)
    # count the expected amount manually (no DB roundtrip) since we
    # don't need the whole multi-PFMP yearly cap calcualtion
    expected = [
      wages[pfmp.mef.id][:daily_rate] * pfmp.day_count,
      wages[pfmp.mef.id][:yearly_cap]
    ].min

    return nil if expected == pfmp.amount

    pfmp.tap { |p| p.amount = expected }
  end

  # sorry
  # rubocop:disable Metrics/AbcSize
  def handle_multiple_pfmps(pfmps)
    updates = []

    pfmps
      .group_by(&:mef)
      .each_value do |grouped_pfmps|
      grouped_pfmps.sort_by(&:created_at).inject(0) do |accumulated, pfmp|
        expected = [
          wages[pfmp.mef.id][:daily_rate] * pfmp.day_count,
          wages[pfmp.mef.id][:yearly_cap] - accumulated
        ].min
        updates << pfmp.tap { |p| p.amount = expected } if expected != pfmp.amount

        accumulated + expected
      end
    end

    updates.flatten
  end
  # rubocop:enable Metrics/AbcSize
end
