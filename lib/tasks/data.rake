# frozen_string_literal: true

ETAB_URL = "/Users/steph/Downloads/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv".freeze

# https://data.education.gouv.fr/explore/dataset/fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre/download?format=csv&timezone=Europe/Berlin&use_labels_for_header=false

require 'csv'
require 'net/http'

namespace :data do
  desc "fetches the public list of establishements and filter out the ones we need"
  task fetch_establishments: :environment do
    # raw = Net::HTTP.get(URI(ETAB_URL))

    raw = File.read(ETAB_URL)

    csv = CSV
            .read(raw, col_sep: ';', headers: true)
            .then { |data| data.filter { |d| d["nature_uai"].start_with? "3" }}

    puts csv.count
  end
end
