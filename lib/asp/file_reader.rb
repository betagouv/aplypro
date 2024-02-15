# frozen_string_literal: true

module ASP
  class FileReader
    include Errors

    attr_reader :filepath, :filename

    FILE_TYPES = %i[rejects integrations payments].freeze

    def initialize(filepath)
      @filepath = filepath
      @filename = File.basename(filepath, ".*")
    end

    FILE_TYPES.each do |type|
      define_method "#{type}_file?" do
        kind == type
      end
    end

    def kind
      case filename
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
               filename.split("integ_idp_").last
             elsif integrations_file?
               filename.split("generes_").last
             end

      "#{name}.xml"
    end

    def request
      @request ||= find_request!
    end

    def find_request!
      ASP::Request
        .with_attached_file
        .find { |request| request.file.filename.to_s == original_filename }
        .tap { |result| raise UnmatchedResponseFile if result.nil? }
    end

    def target_attachment
      request.send "#{kind}_file"
    end

    def attach_to_request!
      target_attachment
        .attach(
          io: File.open(filepath),
          filename: filepath
        )
    end

    def reader_for(kind)
      "ASP::Readers::#{kind.capitalize}FileReader".constantize
    end

    def parse!
      attach_to_request! unless payments_file?

      reader_for(kind).new(File.read(filepath)).process!
    end

    def file_saved?
      target_attachment.attached?
    end
  end
end
