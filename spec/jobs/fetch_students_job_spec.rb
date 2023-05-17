# frozen_string_literal: true

require "rails_helper"

FIXTURE_NAME = "sygne-students-for-uai.json"

RSpec.describe FetchStudentsJob do
  let(:etab) { create(:establishment) }

  before do
    data = Rails.root.join("mock/data", FIXTURE_NAME).read
    url = ENV.fetch "APLYPRO_SYGNE_API"

    stub_request(:get, url)
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Ruby"
        }
      )
      .to_return(status: 200, body: data, headers: {})

    create(:mefstat, code: "1111")
    create(:mefstat, code: "4221")
  end

  it "fetches the students and classes for the etab" do
    described_class.new.perform(etab)

    expect(etab.classes).not_to be_empty
  end
end
