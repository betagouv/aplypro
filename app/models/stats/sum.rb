# frozen_string_literal: true

module Stats
  class Sum < Base
    attr_reader :all, :column

    def initialize(all: 0, column: 0)
      @all = all
      @column = column
      super()
    end

    def global_data
      all.sum(column)
    end

    def bops_data
      @bops_data ||= group_per_bop(all).sum(column).transform_keys { |bop| bop_key_map(bop) }
    end

    def menj_academies_data
      @menj_academies_data ||= group_per_menj_academy(all).sum(column)
    end

    def establishments_data
      @establishments_data ||= group_per_establishment(all).sum(column)
    end
  end
end
