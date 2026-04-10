# frozen_string_literal: true

module ASP
  module ResponseFileHandling
    extend ActiveSupport::Concern

    def parse_response_file!(type)
      reader_for(type).process!
    end

    def attachment_for(type)
      public_send "#{type}_file"
    end

    private

    def reader_for(type)
      klass = "ASP::Readers::#{type.to_s.camelize}FileReader".constantize
      klass.new(io: attachment_for(type).download)
    end
  end
end
