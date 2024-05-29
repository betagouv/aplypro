# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Sygne::Mappers::SchoolingMapper do
  subject(:mapped) { described_class.new.call(data) }

  let(:data) do
    build(
      :sygne_schooling_data,
      :closed,
      start_date: "2024-05-25",
      end_date: "2024-06-01",
      classe_label: "some label",
      school_year: Aplypro::SCHOOL_YEAR,
      mef_code: "1230",
      uai: "007"
    ).tap do |attributes|
      attributes["codeMefRatt"] = attributes["codeMef"]
    end
  end

  it "maps the data correctly" do # rubocop:disable RSpec/ExampleLength, just being nice
    expected = {
      label: "some label",
      mef_code: "123",
      school_year: "2023",
      start_date: "2024-05-25",
      end_date: "2024-06-01",
      status: :student,
      uai: "007"
    }

    expect(mapped).to eq expected
  end
end
