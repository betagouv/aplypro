# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::EstablishmentsController do
  let(:school_year) { SchoolYear.current }
  let(:classe) { create(:classe, school_year: school_year) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:academic_user) }

  before do
    data_row = Array.new(Report::HEADERS.length, 0)
    create(:report, school_year: school_year, data: {
             "establishments_data" => [
               %w[uai establishment_name ministry academy private_or_public] + Report::HEADERS.map(&:to_s),
               [establishment.uai, establishment.name, "MENJ", establishment.academy_label, "Public"] + data_row
             ]
           })

    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return( # rubocop:disable RSpec/AnyInstance
      [establishment.academy_code]
    )
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return(establishment.academy_code) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_school_year).and_return(school_year) # rubocop:disable RSpec/AnyInstance
  end

  describe "GET show" do
    it "returns success" do
      get academic_establishment_path(establishment)
      expect(response).to have_http_status(:success)
    end
  end
end
