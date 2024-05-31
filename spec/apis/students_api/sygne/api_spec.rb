# frozen_string_literal: true

require "rails_helper"
require "./mock/apis/factories/api_student"

describe StudentsApi::Sygne::Api do
  subject(:api) { described_class }

  before do
    mock_sygne_token
    mock_sygne_students_endpoint("007", {}.to_json)
    mock_sygne_student_endpoint_with("007", {}.to_json)
    mock_sygne_student_schoolings_endpoint("123", {}.to_json)
  end

  describe "endpoints" do
    specify "establishment students endpoint" do
      expect(api.establishment_students_endpoint(uai: "007")).to(
        end_with "etablissements/007/eleves/?etat-scolarisation=true"
      )
    end

    specify "invidiual student endpoint" do
      expect(api.student_endpoint(ine: "test")).to end_with "eleves/test"
    end

    specify "student schoolings endpoint" do
      expect(api.student_schoolings_endpoint(ine: "test")).to end_with "eleves/test/scolarites"
    end
  end

  [
    [:establishment_students, { uai: "007" }],
    [:student, { ine: "007" }],
    [:student_schoolings, { ine: "007" }]
  ].each do |resource, params|
    describe "getting #{resource}" do
      it "grabs an access token before calling the API" do
        api.fetch_resource(resource, params)

        expect(WebMock).to have_requested(:post, ENV.fetch("APLYPRO_SYGNE_TOKEN_URL"))
      end

      it "calls the right endpoint" do
        url = api.send "#{resource}_endpoint", params

        api.fetch_resource(resource, params)

        expect(WebMock).to have_requested(:get, url)
      end
    end
  end

  describe "student schoolings" do
    before do
      mock_sygne_student_schoolings_endpoint("123", { "scolarites" => ["foobar"] }.to_json)
    end

    it "returns the array at 'scolarites'" do
      expect(api.fetch_resource(:student_schoolings, ine: 123)).to eq ["foobar"]
    end
  end
end
