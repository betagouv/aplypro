# frozen_string_literal: true

module ActiveModel
  module Type
    class AspDate < Date
      def cast(value)
        parsed = super

        I18n.l(parsed, format: :asp)
      end
    end

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

ActiveModel::Type.register :asp_date, ActiveModel::Type::AspDate
