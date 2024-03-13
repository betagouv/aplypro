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

    def parse!
      persist_file!

      reader = reader_for(kind).new(File.read(filepath))

      begin
        reader.process!
      rescue StandardError => e
        raise ResponseFileParsingError, "couldn't parse #{filename}: #{e}"
      end
    end

    private

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
        .joins(:file_blob)
        .find_by!("active_storage_blobs.filename": original_filename)
    rescue ActiveRecord::RecordNotFound
      raise UnmatchedResponseFile
    end

    def reader_for(kind)
      "ASP::Readers::#{kind.capitalize}FileReader".constantize
    end

    def persist_file!
      if payments_file?
        persist_payment_file!
      else
        attach_to_request!
      end
    end

    def persist_payment_file!
      ASP::PaymentReturn.create_with_file!(io: File.read(filepath), filename: "#{filename}.xml")
    end

    def attach_to_request!
      target_attachment
        .attach(
          io: File.open(filepath),
          filename: filepath
        )
    end

    def target_attachment
      request.send "#{kind}_file"
    end

    def file_saved?
      if payments_file?
        ASP::PaymentReturn.exists?(filename: filename)
      else
        target_attachment.attached?
      end
    end
  end
end
