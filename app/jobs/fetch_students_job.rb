# frozen_string_literal: true

class FetchStudentsJob < ApplicationJob
  queue_as :default

  def perform(etab)
    raw = HTTParty.get(students_url_for(etab))
    data = JSON.parse(raw.body)

    classes = extract_classes(data, etab)

    classes.each(&:save!)
  end

  private

  def extract_classes(data, etab)
    classes = data.group_by { |s| [s["classe"], s["niveau"]] }

    classes.keys.map do |label, mefstat|
      etab.classes.find_or_create_by(label:, mefstat: Mefstat.find_by(code: mefstat))
    end
  end

  def students_url_for(etab)
    URI.parse(ENV.fetch "APLYPRO_SYGNE_API")
  end
end
