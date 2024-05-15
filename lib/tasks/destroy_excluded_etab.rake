# frozen_string_literal: true

namespace :destroy_excluded_etab do
  task destroy: :environment do
    Establishment
      .where(uai: Exclusion.whole_establishment.select(:uai))
      .destroy_all

    Exclusion.outside_contract.each do |exclusion|
      Classe.joins(:establishment, :mef)
            .where(uai: exclusion.uai, "mef.code": exclusion.mef_code)
            .destroy_all
    end
  end
end
