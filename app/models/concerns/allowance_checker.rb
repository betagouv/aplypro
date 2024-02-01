# frozen_string_literal: true

module AllowanceChecker
  extend ActiveSupport::Concern

  included do
    def allowance_left(mef)
      mef.wage.yearly_cap - paid_amount_for_mef(mef)
    end

    private

    def paid_amount_for_mef(mef)
      Payment
        .in_state(:successful, :pending)
        .joins(schooling: :classe)
        .where("classe.mef_id": mef.id, "classe.start_year": ENV.fetch("APLYPRO_SCHOOL_YEAR"))
        .sum(&:amount)
    end
  end
end
