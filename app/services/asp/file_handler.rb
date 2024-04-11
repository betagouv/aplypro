# frozen_string_literal: true

module ASP
  class FileHandler
    include Errors

    attr_reader :filepath, :basename

    FILE_TYPES = %i[rejects integrations payments].freeze

    def initialize(filepath)
      @filepath = filepath
      @basename = File.basename(filepath)
    end

    def parse!
      persist_file!

      reader = reader_for(kind).new(File.read(filepath))

      begin
        reader.process!
      rescue StandardError => e
        raise ResponseFileParsingError, "couldn't parse #{basename}: #{e}"
      end
    end

    def file_saved?
      target_attachment.attached?
    end

    private

    FILE_TYPES.each do |type|
      define_method "#{type}_file?" do
        kind == type
      end
    end

    def kind
      case basename
      when /^rejets_integ_idp/
        :rejects
      when /^identifiants_generes/
        :integrations
      else
        :payments
      end
    end

    def reader_for(kind)
      "ASP::Readers::#{kind.capitalize}FileReader".constantize
    end

    def original_filename
      return if payments_file?

      filename_noext = File.basename(basename, ".*")

      name = if rejects_file?
               filename_noext.split("integ_idp_").last
             elsif integrations_file?
               filename_noext.split("generes_").last
             end

      "#{name}.xml"
    end

    def persist_file!
      target_attachment
        .attach(
          io: StringIO.new(File.read(filepath)),
          filename: basename
        )
    end

    def record
      @record ||= find_record!
    end

    def find_record!
      if payments_file?
        ASP::PaymentReturn.find_or_create_by!(filename: basename)
      else
        ASP::Request
          .joins(:file_blob)
          .find_by!("active_storage_blobs.filename": original_filename)
      end
    rescue ActiveRecord::RecordNotFound
      raise UnmatchedResponseFile
    end

    def target_attachment
      if payments_file?
        record.file
      else
        record.send "#{kind}_file"
      end
    end
  end
end
