# frozen_string_literal: true

module Academic
  module StatsHelper
    def format_stat_value(value, indicator_type: nil)
      return handle_special_values(value) unless valid_numeric?(value)

      if currency_indicator?(indicator_type)
        number_to_currency(value, unit: "€", separator: ",", delimiter: " ", precision: 2)
      elsif ratio_value?(value)
        number_to_percentage(value * 100, precision: 2, separator: ",")
      elsif integer_value?(value)
        number_with_delimiter(value.to_i, delimiter: " ")
      else
        number_with_precision(value, precision: 2, separator: ",", delimiter: " ")
      end
    end

    def cell_background_color(value)
      return "" unless value.is_a?(Numeric) && ratio_value?(value)

      if value >= 0.8
        "background-color: var(--success-950-100);"
      elsif value >= 0.5
        "background-color: var(--yellow-tournesol-975-75);"
      elsif value >= 0.2
        "background-color: var(--yellow-tournesol-850-200);"
      else
        "background-color: var(--red-marianne-950-100);"
      end
    end

    def visible_columns(data)
      return [] if data.empty?

      headers = data.first
      (0...headers.length).reject { |index| column_empty?(data, index) }
    end

    def format_table_header(key)
      return key.to_s unless key.is_a?(Symbol) || key.is_a?(String)

      symbol_key = key.is_a?(Symbol) ? key : key.to_sym
      I18n.t("activerecord.attributes.report.#{symbol_key}", default: symbol_key.to_s.humanize)
    end

    private

    def handle_special_values(value)
      return "N/A" if value.nil?
      return "Infini" if value.respond_to?(:infinite?) && value.infinite?
      return "0" if value.respond_to?(:nan?) && value.nan?

      value.to_s
    end

    def valid_numeric?(value)
      value.is_a?(Numeric)
    end

    def currency_indicator?(indicator_type)
      indicator_type == "Stats::Sum"
    end

    def ratio_value?(value)
      value.is_a?(Float) && value >= 0 && value <= 1
    end

    def integer_value?(value)
      value.is_a?(Integer) || (value.is_a?(Numeric) && value == value.to_i)
    end

    def column_empty?(data, column_index)
      data[1..].all? do |row|
        value = row[column_index]
        value.nil? || (value.respond_to?(:nan?) && value.nan?)
      end
    end
  end
end
