# frozen_string_literal: true

module ASP
  class SchemaValidator < ActiveModel::Validator
    def validate(file)
      document = Nokogiri::XML::Document.parse(file.to_xml)

      schema.validate(document).each do |error|
        file.errors.add(:base, :invalid, message: error.to_s)
      end
    end

    private

    def schema
      @schema ||= Nokogiri::XML::Schema(Rails.root.join("lib/asp/schema.xsd").read)
    end
  end
end
