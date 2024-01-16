# frozen_string_literal: true

class AspDateType < ActiveModel::Type::Date
  def cast(value)
    parsed = super(value)

    I18n.l(parsed, format: :asp)
  end
end

ActiveModel::Type.register :asp_date, AspDateType
