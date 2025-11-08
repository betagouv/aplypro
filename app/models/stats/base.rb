# frozen_string_literal: true

module Stats
  class Base
    def self.key
      raise NotImplementedError
    end

    def self.title
      raise NotImplementedError
    end

    def self.tooltip_key
      nil
    end

    delegate :key, :title, :tooltip_key, to: :class

    def with_mef_and_establishment
      raise NotImplementedError
    end

    def with_establishment
      raise NotImplementedError
    end

    def global_data
      raise NotImplementedError
    end

    def bops_data
      raise NotImplementedError
    end

    def menj_academies_data
      raise NotImplementedError
    end

    def establishments_data
      raise NotImplementedError
    end

    # NOTE: the only truly valid reference to the ministry is in Mef not in Establishments
    #       the value stored in establishments is useless for now (no used, as of 14.05.24)
    #       ENPU -> Education Nationale PUblique, ENPR -> Education Nationale PRivée
    def bop
      Arel.sql(
        %(
          CASE mefs.ministry
          WHEN 0 THEN (CASE private_contract_type_code WHEN '99' THEN 'ENPU' ELSE 'ENPR' END)
          ELSE mefs.ministry::text END
        )
      )
    end

    def bop_key_map(bop)
      %w[ENPU ENPR].include?(bop) ? bop : Mef.ministries.invert[bop.to_i].upcase
    end

    def group_per_bop(collection)
      collection.merge(with_mef_and_establishment)
                .group(bop)
    end

    def group_per_menj_academy(collection)
      collection.merge(with_mef_and_establishment)
                .where("mefs.ministry": :menj)
                .order(:academy_label)
                .group(:academy_label)
    end

    def group_per_establishment(collection)
      collection.merge(with_establishment)
                .order(:uai)
                .group(:uai)
    end
  end
end
