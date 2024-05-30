# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Sygne::Mappers::StudentMapper do
  subject(:mapper) { described_class.new }

  let(:attributes) do
    build(
      :sygne_student,
      :male,
      ine_value: "007",
      first_name: "Marie",
      last_name: "Curie",
      birthdate: "13/07/1990"
    )
  end

  it "maps correctly" do # rubocop:disable RSpec/ExampleLength, just being nice
    expected = {
      first_name: "Marie",
      biological_sex: :male,
      ine: "007",
      last_name: "Curie",
      birthdate: "13/07/1990"
    }

    # this test looks dumb because the arguments for `attributes` and
    # `expected` are similar but `attributes` actually ends up being a
    # SYGNE-like payload; c.f puts attributes
    expect(mapper.call(attributes)).to eq expected
  end
end
