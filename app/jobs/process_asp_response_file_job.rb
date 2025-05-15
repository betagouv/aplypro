# frozen_string_literal: true

class ProcessASPResponseFileJob < ApplicationJob
  queue_as :payments
  attr_reader :record, :filename

  def perform(raw_filename)
    @filename = ASP::Filename.new(raw_filename)

    @record = ActiveStorage::Blob
              .find_by!("active_storage_blobs.filename": filename.to_s)
              .attachments
              .first
              .record
    process_file
  rescue ASP::Errors::IntegrationError => e
    attempt_resolve(e)
  end

  private

  def process_file
    ApplicationRecord.transaction do
      record.parse_response_file!(filename.kind)
    end
  end

  def attempt_resolve(error)
    raise error unless error.message.include?("index_students_on_asp_individu_id")

    StudentMerger.new(error.payment_request.student.duplicates.to_a).merge!
    process_file
  end
end
