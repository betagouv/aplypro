# frozen_string_literal: true

require "csv"
require "net/http"

def log_around(msg, &block)
  logger = ActiveSupport::TaggedLogging.new(Rails.logger).tagged("DATA")

  logger.debug("#{msg}...")

  block.call(logger)
       .tap { logger.debug("#{msg}... done") }
end

def download_to(uri, path)
  log_around "Downloading #{uri} into #{path}" do
    File.write(path, Net::HTTP.get(URI(uri)).force_encoding("UTF-8"))
  end
end

def check_cached_file(path)
  log_around "Checking for #{path}" do |logger|
    if File.exist?(path)
      logger.debug("#{path} exists, returning that instead.")
      File.read(path)
    end
  end
end

def fetch_and_save(uri, path)
  check_cached_file(path) || download_to(uri, path)
end

namespace :data do
  desc "fetches the public list of establishements and filter out the ones we need"
  task fetch_establishments: :environment do
    log_around "Fetching establishments" do
      raw = fetch_and_save(
        URI(Establishment::BOOTSTRAP_URL),
        Rails.root.join("/tmp/list-etabs.csv")
      )

      log_around "Parsing the CSV file" do
        attributes = CSV
                     .parse(raw, col_sep: ";", headers: true)
                     .map { |data| Establishment.from_csv(data) }
                     .select(&:second_degree?)
                     .reject { |e| e.name.blank? }
                     .map { |etab| etab.attributes.merge(created_at: DateTime.now, updated_at: DateTime.now) }

        Establishment.upsert_all(attributes) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end

  desc "fetches the public list of mefstats and filter out the ones we need"
  task fetch_mefstats: :environment do
    log_around "Fetching mefstats" do
      raw = fetch_and_save(
        URI(Mefstat::BOOTSTRAP_URL),
        Rails.root.join("tmp/list-mefstats.csv")
      )

      log_around "Parsing the CSV file" do
        attributes = CSV
                     .parse(raw, col_sep: ";", headers: true)
                     .map { |data| Mefstat.from_csv(data) }
                     .uniq(&:id)
                     .map { |mefstat| mefstat.attributes.merge(created_at: DateTime.now, updated_at: DateTime.now) }

        Mefstat.upsert_all(attributes) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
