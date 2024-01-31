# frozen_string_literal: true

module Stats
  class Count < Base
    attr_reader :all

    def initialize(all: 0)
      @all = all
      super()
    end

    def global_data
      all.count
    end

    def bops_data
      @bops_data ||= group_per_bop(all).count.transform_keys { |bop| bop_key_map(bop) }
    end

    def menj_academies_data
      @menj_academies_data ||= group_per_menj_academy(all).count
    end

    def establishments_data
      @establishments_data ||= group_per_establishment(all).count
    end
  end
end
