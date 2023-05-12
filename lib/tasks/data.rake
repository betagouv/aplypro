# frozen_string_literal: true

require "csv"
require "net/http"

def fetch_and_save(uri, path)
  return File.read(path) if File.exist?(path)

  data = Net::HTTP.get(uri)

  File.write(path, data.force_encoding("UTF-8"))

  return data
end

namespace :data do
  desc "fetches the public list of establishements and filter out the ones we need"
  task fetch_establishments: :environment do
    Rails.logger.info "Fetching the CSV file..."

    raw = fetch_and_save(
      URI(Establishment::BOOTSTRAP_URL),
      Rails.root.join("tmp/list-etabs.csv")
    )

    Rails.logger.info "Parsing the CSV file..."

    attributes = CSV
                 .parse(raw, col_sep: ";", headers: true)
                 .map { |data| Establishment.from_csv(data) }
                 .select(&:second_degree?)
                 .reject(&:invalid?)
                 .map { |etab| etab.attributes.merge(created_at: DateTime.now, updated_at: DateTime.now) }

    Establishment.upsert_all(attributes)
  end
end
