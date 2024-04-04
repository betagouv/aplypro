# frozen_string_literal: true

class AspDateType < ActiveModel::Type::Date
  def cast(value)
    parsed = super(value)

    I18n.l(parsed, format: :asp)
  end
end

module ActiveModel
  module Type
    class String
      def cast(value)
        if @limit
          super(value.to_s.first(@limit))
        else
          super
        end
      end
    end
  end
end

ActiveModel::Type.register :asp_date, AspDateType
