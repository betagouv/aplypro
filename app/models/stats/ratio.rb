# frozen_string_literal: true

module Stats
  class Ratio < Base
    attr_reader :subset, :all

    def initialize(subset: 0, all: 0)
      @subset = subset
      @all = all
      super()
    end

    def global_data
      subset.count.to_f / all.count
    end

    def bops_data
      @bops_data ||= data_per_attribute(:group_per_bop, key_map: :bop_key_map)
    end

    def menj_academies_data
      @menj_academies_data ||= data_per_attribute(:group_per_menj_academy)
    end

    def establishments_data
      @establishments_data ||= data_per_attribute(:group_per_establishment)
    end

    def data_per_attribute(group_method, key_map: nil)
      subset_counted_per_attribute = send(group_method, subset).count
      all_counted_per_attribute = send(group_method, all).count

      subset_counted_per_attribute.to_h do |attribute, subset_count|
        all_count = all_counted_per_attribute[attribute]
        attribute = send(key_map, attribute) if key_map.present?
        ratio = subset_count.to_f / all_count
        [attribute, ratio]
      end
    end
  end
end
