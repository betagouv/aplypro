# frozen_string_literal: true

module AllowanceChecker
  extend ActiveSupport::Concern

  included do
    def allowance_left(mef)
      mef.wage.yearly_cap - paid_amount_for_mef(mef)
    end

    private

    def paid_amount_for_mef(mef)
      pfmps
        .joins(:classe)
        .where.not(amount: nil)
        .where("classe.mef_id": mef.id, "classe.start_year": ENV.fetch("APLYPRO_SCHOOL_YEAR"))
        .sum(&:amount)
    end
  end
end
