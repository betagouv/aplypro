# frozen_string_literal: true

require "attribute_decision_generator"

class GenerateAttributiveDecisionsJob < ApplicationJob
  # this job touches on I/O quite a lot so we've got a separate
  # "documents" queue that is configured in Docker and Scalingo to
  # run a single thread and avoid concurrency issue.
  queue_as :documents

  ARCHIVE_ROOT = Rails.root.join("tmp/archives")

  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(generating_attributive_decisions: true)

    FileUtils.mkdir_p(ARCHIVE_ROOT)

    Dir.chdir(ARCHIVE_ROOT) do
      block.call
    end

    establishment.update!(generating_attributive_decisions: false)
  end

  def perform(establishment)
    filename = attributive_decisions_zip_filename(establishment)

    Zip::File.open(filename, create: true) do |zipfile|
      generate_attributive_decisions_zip!(zipfile, establishment)
    end

    establishment.rattach_attributive_decisions_zip!(File.open(filename), filename)
  end

  def fetch_student_address!(student)
    FetchStudentAddressJob.new(student).perform_now
  rescue Faraday::Error => e
    Sentry.capture_exception(e)
  end

  def create_zip_file(zipfile, schooling)
    target = File.join(schooling.classe.label, schooling.attributive_decision_filename)

    Tempfile.create do |file|
      AttributeDecisionGenerator.new(schooling).generate!(file)

      file.rewind

      schooling.rattach_attributive_decision!(file)

      zipfile.add(target, file)
      zipfile.commit
    end
  end

  def generate_attributive_decisions_zip!(zipfile, establishment)
    establishment.current_schoolings.each do |schooling|
      fetch_student_address!(schooling.student) if schooling.student.missing_address?
      create_zip_file(zipfile, schooling)
    end
  end

  def attributive_decisions_zip_filename(establishment)
    today = I18n.l(DateTime.now, format: "%d_%m_%Y")

    "decisions_attributions-#{establishment.uai}-#{today}.zip"
  end
end
