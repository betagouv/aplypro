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
    Schooling.where(start_date: nil, end_date: nil).find_each do |schooling|
      establishment = schooling.establishment
      student = schooling.student
      provider = establishment.students_provider
      data = StudentsApi.api_for(provider).fetch_resource("student", { ine: student.ine })

      if data.present?
        case provider
        when "fregata"
          schooling.update!(start_date: data["dateEntreeFormation"], end_date: data["dateSortieFormation"])
        when "sygne"
          scolarite = data["scolarite"]
          schooling.update!(start_date: scolarite["dateDebSco"], end_date: scolarite["dateFinSco"])
        else
          puts "no matching API found for #{provider}"
        end
      end
    end
  end
end
