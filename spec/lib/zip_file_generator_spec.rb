# frozen_string_literal: true

require "rails_helper"
require "zip_file_generator"

RSpec.describe ZipFileGenerator do
  let(:input_dir) { "./spec/lib/zip_test_folder" }
  let(:output_file) { "zipped_folder.zip" }
  let(:zip_file_generator) { described_class.new(input_dir, output_file) }
  let(:expected_archive_content) do
    ["file_1.txt", "subfolder_2/", "subfolder_2/subfolder_2.1/",
     "subfolder_2/subfolder_2.1/file_4.txt", "subfolder_2/file_3.txt", "subfolder_1/", "subfolder_1/file_2.txt"]
  end

  describe "write" do
    before do
      zip_file_generator.write
    end

    after do
      FileUtils.rm_f(output_file)
    end

    it "creates a zip archive" do
      expect(File.exist?(output_file)).to be true
    end

    it "creates a zip archive containing all subfolders contents" do
      Zip::File.open(output_file) do |zip_file|
        files = zip_file.entries.map(&:name)
        expect(files.sort).to eq(expected_archive_content.sort)
      end
    end
  end
end
