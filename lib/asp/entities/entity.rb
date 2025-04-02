# frozen_string_literal: true

module ASP
  module Entities
    class Entity
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

      attr_reader :payment_request

      ASP_MODIFICATION = { modification: "O" }.freeze
      ASP_NO_MODIFICATION = { modification: "N" }.freeze

      class << self
        def payment_mapper_class
          klass = name.demodulize

          "ASP::Mappers::#{klass}Mapper".constantize
        end

        def from_payment_request(payment_request)
          raise ArgumentError, "cannot make a #{name} instance with a nil payment" if payment_request.nil?

          mapper = payment_mapper_class.new(payment_request)

          new.tap do |instance|
            instance.instance_variable_set(:@payment_request, payment_request)

            mapped_attributes = attribute_names.index_with do |attr|
              mapper.send(attr) if mapper.respond_to?(attr)
            end

            instance.assign_attributes(mapped_attributes)
          end
        end

        def known_with(attr)
          define_method(:new_record?) { send(attr).blank? }
          define_method(:known_record?) { !new_record? }
        end
      end

      def xml_root_args
        {}
      end

      def to_xml(builder)
        args = xml_root_args

        validate!

        builder.tap do |xml|
          xml.send(root_node_name, args) do |x|
            fragment(x)
          end
        end
      end

      def root_node_name
        self.class.name.demodulize.downcase
      end

      def adresse_entity_class
        if payment_request.pfmp.rectified?
          payment_request.student.lives_in_france? ? Adresse::InduFrance : Adresse::InduEtranger
        else
          payment_request.student.lives_in_france? ? Adresse::France : Adresse::Etranger
        end
      end
    end
  end
end
