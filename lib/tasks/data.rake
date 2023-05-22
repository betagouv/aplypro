# frozen_string_literal: true

require "csv"
require "net/http"
require_relative "../fetcher"

AUTO_KEYS = %w[id created_at updated_at].freeze

namespace :data do
  desc "fetches the public list of establishements and filter out the ones we need"
  task fetch_establishments: :environment do
    raw = Fetcher.new(Establishment::BOOTSTRAP_URL).read

    models = CSV
             .parse(raw, col_sep: ";", headers: true)
             .map { |data| Establishment.from_csv(data) }
             .select(&:second_degree?)
             .reject { |e| e.name.blank? }
             .map(&:attributes)
             .map { |h| h.except(*AUTO_KEYS) }

    Establishment.insert_all(models) # rubocop:disable Rails/SkipsModelValidations
  end

  desc "fetches the public list of mefstats and filter out the ones we need"
  task fetch_mefstats: :environment do
    raw = Fetcher.new(Mefstat::BOOTSTRAP_URL).read

    models = CSV
             .parse(raw, col_sep: ";", headers: true)
             .map { |data| Mefstat.from_csv(data) }
             .uniq(&:code)
             .map(&:attributes)
             .map { |h| h.except(*AUTO_KEYS) }

    Mefstat.insert_all(models) # rubocop:disable Rails/SkipsModelValidations
  end
end
