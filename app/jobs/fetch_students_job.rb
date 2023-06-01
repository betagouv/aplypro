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

    classes.map do |classe, eleves|
      label, mefstat = classe

      etab
        .classes
        .find_or_create_by(label:, mefstat: Mefstat.find_by(code: mefstat))
        .tap do |c|
        c.students << eleves.map { |e| Student.from_sygne_hash(e) }
      end
    end
  end

  def students_url_for(etab)
    URI.parse(ENV.fetch("APLYPRO_SYGNE_API") % etab.uai)
  end
end
