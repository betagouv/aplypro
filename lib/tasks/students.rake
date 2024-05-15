# frozen_string_literal: true

require "csv"

namespace :students do
  task :csv_import, %i[filepath uai] => :environment do |_t, args|
    filepath = args[:filepath]
    uai = args[:uai]

    puts "Going to import for UAI #{uai} with CSV at #{filepath}..."

    data = File.read(filepath)

    CSVImporter.new(data, uai).parse!
  end
end
