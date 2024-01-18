# frozen_string_literal: true

module ASP
  module Entities
    class Entity
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

      attr_reader :payment

      class << self
        def payment_mapper_class
          klass = name.demodulize

          "ASP::Mappers::#{klass}Mapper".constantize
        end

        def from_payment(payment)
          raise ArgumentError, "cannot make a #{name} instance with a nil payment" if payment.nil?

          mapper = payment_mapper_class.new(payment)

          new.tap do |instance|
            instance.instance_variable_set(:@payment, payment)

            mapped_attributes = attribute_names.index_with do |attr|
              mapper.send(attr) if mapper.respond_to?(attr)
            end

            instance.assign_attributes(mapped_attributes)
          end
        end
      end

      def to_xml(builder)
        validate!

        builder.tap { |xml| fragment(xml) }
      end

      def fragment(builder)
        raise NotImplementedError
      end
    end
  end
end
