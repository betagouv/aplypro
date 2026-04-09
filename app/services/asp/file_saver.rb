# frozen_string_literal: true

module ASP
  class FileSaver
    include Errors

    attr_reader :file, :filename

    def initialize(file)
      @file = file
      @filename = ASP::Filename.new(File.basename(file))
    end

    def persist_file!
      target_attachment
        .attach(
          io: StringIO.new(file.read),
          filename: filename
        )
    end

    private

    def record
      @record ||= find_record!
    end

    def find_record!
      find_payment_return_or_request!
    rescue ActiveRecord::RecordNotFound
      raise UnmatchedResponseFile
    end

    def find_payment_return_or_request!
      if filename.payments_file? || filename.rectifications_file?
        ASP::PaymentReturn.find_or_create_by!(filename: filename.to_s)
      else
        ASP::Request.joins(source_blob).find_by!("active_storage_blobs.filename": filename.original_filename).tap do |record|
          record.correction_adresse = correction_adresse_response?
        end
      end
    end

    def source_blob
      correction_adresse_response? ? :correction_adresse_file_blob : :file_blob
    end

    def correction_adresse_response?
      filename.correction_adresse_integrations_file? || filename.correction_adresse_rejects_file?
    end

    def target_attachment
      if filename.payments_file?
        record.file
      else
        record.public_send "#{filename.kind}_file"
      end
    end
  end
end
