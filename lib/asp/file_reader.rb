# frozen_string_literal: true

module ASP
  class FileReader
    attr_reader :filepath

    FILE_TYPES = %i[rejects integrations payments].freeze

    def initialize(filepath)
      @filepath = filepath
    end

    FILE_TYPES.each do |type|
      define_method "#{type}_file?" do
        kind == type
      end
    end

    def kind
      case File.basename(filepath)
      when /^rejets_integ_idp/
        :rejects
      when /^identifiants_generes/
        :integrations
      else
        :payments
      end
    end

    def original_filename
      return if payments_file?

      name = if rejects_file?
               File.basename(filepath, ".*").split("integ_idp_").last
             elsif integrations_file?
               File.basename(filepath, ".*").split("generes_").last
             end

      "#{name}.xml"
    end

    def request
      @request ||= find_request!
    end

    def find_request!
      blob = ActiveStorage::Blob.find_by!(filename: original_filename)

      attachment = ActiveStorage::Attachment.find_by!(blob: blob)

      ASP::Request.find(attachment.record_id)
    end

    def attach_to_request!
      slot = request.send "#{kind}_file"

      slot.attach(io: File.open(filepath), filename: filepath)
    end

    def reader_for(kind)
      "ASP::Readers::#{kind.capitalize}FileReader".constantize
    end

    def parse!
      attach_to_request! unless payments_file?

      reader_for(kind).new(filepath).process!
    end
  end
end
