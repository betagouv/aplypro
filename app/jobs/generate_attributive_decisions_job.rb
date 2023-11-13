# frozen_string_literal: true

require "attribute_decision_generator"

class GenerateAttributiveDecisionsJob < ApplicationJob
  queue_as :default

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
