# frozen_string_literal: true

module ASP
  module Entities
    class Entity
      include ActiveModel::API
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment

      module StudentMapper
        def student_mapper_class
          raise NotImplementedError
        end

        def from_student(student)
          mapper = student_mapper_class.new(student)

          new.tap do |instance|
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
