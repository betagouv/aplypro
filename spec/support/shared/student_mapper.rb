# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a student mapper" do
  let(:result) { mapper.map_payload(data, etab) }

  it "returns an array of Classes" do
    expect(result).to be_an_array_of Classe
  end

  it "parses all the students" do
    expect(result.map(&:students).flatten.length).to eq data.length
  end

  it "upserts the classes" do
    result.each(&:save)

    expect { result.each(&:save!) }.not_to change(Classe, :count)
  end

  it "upserts the students" do
    result.each(&:save!)

    expect { result.each(&:save!) }.not_to change(Student, :count)
  end
end
