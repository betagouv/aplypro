# frozen_string_literal: true

module ASP
  module Entities
    class Entity
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

      attr_reader :payment

      ASP_NO_MODIFICATION = { modification: "N" }.freeze

      class << self
        def payment_mapper_class
          klass = name.demodulize

          "ASP::Mappers::#{klass}Mapper".constantize
        end

        def from_payment_request(payment)
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

      def xml_root_args
        {}
      end

      def to_xml(builder)
        root_node = self.class.name.demodulize.downcase
        args = xml_root_args

        validate!

        builder.tap do |xml|
          xml.send(root_node, args) do |x|
            fragment(x)
          end
        end
      end
    end
  end
end
