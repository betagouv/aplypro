# frozen_string_literal: true

class ProcessASPResponseFileJob < ApplicationJob
  queue_as :payments_serial

  def perform(raw_filename)
    filename = ASP::Filename.new(raw_filename)

    record = ActiveStorage::Blob
             .find_by!("active_storage_blobs.filename": filename.to_s)
             .attachments
             .first
             .record

    ActiveRecord::Base.transaction do
      record.parse_response_file!(filename.kind)
    end
  end
end
