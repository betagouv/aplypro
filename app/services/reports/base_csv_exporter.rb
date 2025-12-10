# frozen_string_literal: true

module Reports
  module BaseCSVExporter
    private

    def format_cell_for_csv(cell)
      return "0" if cell.nil?
      return "Infini" if cell.respond_to?(:infinite?) && cell.infinite?
      return "0" if cell.respond_to?(:nan?) && cell.nan?
      return cell.to_s unless cell.is_a?(Numeric)

      rounded_value = round_value(cell)
      rounded_value.to_s.gsub(".", ",")
    end

    def round_value(value)
      return value.to_i if integer_value?(value)

      value.round(2)
    end

    def integer_value?(value)
      value.is_a?(Integer) || (value.is_a?(Numeric) && value == value.to_i)
    end
  end
end
