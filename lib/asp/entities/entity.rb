# frozen_string_literal: true

module ASP
  module Entities
    class Entity
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

      attr_reader :payment_request, :payment_requests

      ASP_MODIFICATION = { modification: "O" }.freeze
      ASP_NO_MODIFICATION = { modification: "N" }.freeze

      class << self
        def from_payment_requests(payment_requests)
          from("payment_requests", payment_requests)
        end

        def from_payment_request(payment_request)
          from("payment_request", payment_request)
        end

        def from(variable_name, variable_value)
          raise ArgumentError, "cannot make a #{name} instance with a nil" if variable_value.nil?

          mapper = mapper_class.new(variable_value)

          new.tap do |instance|
            instance.instance_variable_set(:"@#{variable_name}", variable_value)

            mapped_attributes = attribute_names.index_with do |attr|
              mapper.send(attr) if mapper.respond_to?(attr)
            end

            instance.assign_attributes(mapped_attributes)
          end
        end

        def mapper_class
          klass = name.demodulize

          "ASP::Mappers::#{klass}Mapper".constantize
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
        student = payment_request.nil? ? payment_requests.first.student : payment_request.student
        if payment_request.present? && payment_request.pfmp.rectified?
          student.lives_in_france? ? Adresse::InduFrance : Adresse::InduEtranger
        else
          student.lives_in_france? ? Adresse::France : Adresse::Etranger
        end
      end
    end
  end
end
