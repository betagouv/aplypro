# frozen_string_literal: true

module Stats
  class Ratio < Base
    def initialize(numerator_indicator:, denominator_indicator:)
      @numerator_indicator = numerator_indicator
      @denominator_indicator = denominator_indicator
      super()
    end

    def global_data
      @global_data ||= compute_ratio_from_indicators(:global_data)
    end

    def bops_data
      @bops_data ||= compute_ratio_from_indicators(:bops_data)
    end

    def menj_academies_data
      @menj_academies_data ||= compute_ratio_from_indicators(:menj_academies_data)
    end

    def establishments_data
      @establishments_data ||= compute_ratio_from_indicators(:establishments_data)
    end

    def calculate_ratio(subset_count, all_count)
      all_count.nil? || all_count.zero? ? 0.0 / 0 : subset_count.to_f / all_count
    end

    private

    def compute_ratio_from_indicators(data_method)
      numerator_data = compute_data(@numerator_indicator, data_method)
      denominator_data = compute_data(@denominator_indicator, data_method)

      compute_ratio(numerator_data, denominator_data)
    end

    def compute_data(indicator, data_method)
      indicator.send(data_method)
    end

    def compute_ratio(numerator_data, denominator_data)
      if numerator_data.is_a?(Hash)
        compute_ratio_for_each_key(numerator_data, denominator_data)
      else
        calculate_ratio(numerator_data, denominator_data)
      end
    end

    def compute_ratio_for_each_key(numerator_hash, denominator_hash)
      all_keys = (numerator_hash.keys + denominator_hash.keys).uniq
      all_keys.to_h do |key|
        numerator = numerator_hash[key] || 0
        denominator = denominator_hash[key] || 0
        [key, calculate_ratio(numerator, denominator)]
      end
    end
  end
end
