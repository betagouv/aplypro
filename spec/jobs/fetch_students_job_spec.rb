# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchStudentsJob do
  let(:etab) { create(:establishment) }

  before do
    fixture = "sygne-students-for-uai.json"
    data = Rails.root.join("mock/data", fixture).read

    stub_request(:get, %r{http://mock:3002/sygne/generated/*})
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

  it "creates a bunch of student" do
    expect { described_class.new.perform(etab) }.to change(Student, :count).by(2)
  end
end
