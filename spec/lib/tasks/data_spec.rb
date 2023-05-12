# frozen_string_literal: true

require "rails_helper"

FIXTURE_NAME = "fr-en-adresse-et-geolocalisation-etablissements-premier-et-second-degre.csv"

describe "Data tasks", type: :task do
  subject(:task) { Rake::Task["data:fetch_establishments"] }

  after do
    task.reenable
  end

  before do
    data = Rails.root.join("spec/fixtures", FIXTURE_NAME).read

    stub_request(:get, Establishment::BOOTSTRAP_URL)
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Host" => "data.education.gouv.fr",
          "User-Agent" => "Ruby"
        }
      )
      .to_return(status: 200, body: data, headers: {})

    Aplypro::Application.load_tasks
  end

  it "parses and saves a collection of Establishements" do
    expect { task.invoke }.to change(Establishment, :count)
  end

  it "rejects schools we don't care about" do
    task.invoke

    expect(Establishment.all.map(&:denomination).uniq).not_to include(*["ECOLE MATERNELLE PUBLIQUE", "ECOLE PRIMAIRE", "ECOLE ELEMENTAIRE PUBLIQUE"])
  end
end
