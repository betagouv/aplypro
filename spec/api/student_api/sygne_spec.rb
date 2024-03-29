# frozen_string_literal: true

require "rails_helper"
require "./mock/factories/api_student"

describe StudentApi::Sygne do
  subject(:api) { described_class.new(establishment.uai) }

  let(:establishment) { create(:establishment, :sygne_provider) }
  let(:data) { Rails.root.join("mock/data/sygne-students-for-uai.json").read }
  let(:student_data) { Rails.root.join("mock/data/sygne-student.json").read }

  before do
    mock_sygne_token
    mock_sygne_students_endpoint(establishment.uai, data)
  end

  it "grabs an access token before calling the API" do
    api.fetch!

    expect(WebMock).to have_requested(:post, ENV.fetch("APLYPRO_SYGNE_TOKEN_URL"))
  end

  it "calls the correct endpoint" do
    api.fetch!

    expect(WebMock).to have_requested(:get, %r{etablissements/#{establishment.uai}/eleves})
  end

  describe "fetch_student_data!" do
    let(:student) { create(:student) }

    before do
      mock_sygne_student_endpoint_with(student.ine, student_data)
    end

    it "needs to be called with an INE" do
      expect { api.fetch_student_data! }.to raise_error ArgumentError
    end

    it "calls the correct endpoint" do
      api.fetch_student_data!(student.ine)

      expect(WebMock).to have_requested(:get, %r{/eleves/#{student.ine}})
    end

    it "returns the parsed data" do
      response = api.fetch_student_data!(student.ine)

      expect(response).to be_a Hash
    end
  end
end
