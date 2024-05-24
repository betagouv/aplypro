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

  task update_schoolings_status: :environment do
    Schooling.where(status: nil).each do |schooling|
      establishment = schooling.establishment
      student = schooling.student
      provider = establishment.students_provider

      data = StudentApi.fetch_student_data!(provider, establishment.uai, student.ine)

      case provider
      when "fregata"
        unless data.nil?
          schooling.update(:start_date => data["dateEntreeFormation"])
        end
      when "sygne"
        scolarite = data["scolarite"]
        schooling.update(:start_date => scolarite["dateDebSco"])
      else
        puts "no matching API found for #{provider}"
      end
    end
  end
end
