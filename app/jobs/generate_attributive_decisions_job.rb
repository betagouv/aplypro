# frozen_string_literal: true

require "attribute_decision_generator"
require "zip_file_generator"

class GenerateAttributiveDecisionsJob < ApplicationJob
  queue_as :default

  around_perform do |job, block|
    establishment = job.arguments.first

    establishment.update!(generating_attributive_decisions: true)

    block.call

    establishment.update!(generating_attributive_decisions: false)
  end

  def perform(establishment)
    create_establishment_folder(establishment)

    generate_all_attributive_decisions(establishment)

    generate_attributive_decisions_zip(establishment)

    cleanup_temporary_files
  end

  def generate_all_attributive_decisions(establishment)
    establishment.classes.current.includes(:schoolings).find_each do |classe|
      create_classe_folder(classe)
      generate_classe_attributive_decisions(classe)
    end
  end

  def generate_classe_attributive_decisions(classe)
    classe.schoolings.each do |schooling|
      generate_schooling_attributive_decision(schooling)
    end
  end

  def generate_schooling_attributive_decision(schooling)
    classe_folder_name = classe_folder_name(schooling.classe)
    file_path = "#{classe_folder_name}/#{schooling.attributive_decision_filename}"

    File.open(file_path, "w+") do |file|
      generate_and_attach_ad_to_schooling(schooling, file)
    end
  end

  def generate_and_attach_ad_to_schooling(schooling, file)
    AttributeDecisionGenerator.new(schooling.student).generate!(file)

    file.rewind

    schooling.rattach_attributive_decision!(file)
  end

  def generate_attributive_decisions_zip(establishment)
    @zip_name = "tmp/archives/#{establishment.attributive_decisions_zip_filename}"
    ZipFileGenerator.new(establishment_folder_name(establishment), @zip_name).write

    File.open(@zip_name, "r") do |file|
      establishment.rattach_attributive_decisions_zip!(file)
    end
  end

  def establishment_folder_name(establishment)
    "tmp/archives/etab_#{establishment.uai}"
  end

  def classe_folder_name(classe)
    "#{establishment_folder_name(classe.establishment)}/#{classe.label}"
  end

  def create_establishment_folder(establishment)
    @etab_folder_name = establishment_folder_name(establishment)
    FileUtils.mkdir_p(@etab_folder_name)
  end

  def create_classe_folder(classe)
    FileUtils.mkdir_p(classe_folder_name(classe))
  end

  def cleanup_temporary_files
    FileUtils.rm_rf(@etab_folder_name)
    FileUtils.rm(@zip_name)
  end
end
