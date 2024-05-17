# frozen_string_literal: true

require "rails_helper"

describe CSVImporter do
  subject(:importer) { described_class.new(fixture, establishment.uai) }

  let(:fixture) { File.read(File.join(__dir__, "csv_importer_fixture.csv")) }
  let(:establishment) { create(:establishment) }

  before do
    double = instance_double(Student::Mappers::CSV)

    stub_const("Student::Mappers::CSV", class_double(Student::Mappers::CSV, new: double))

    allow(double).to receive(:parse!).and_return :result
  end

  context "when then headers are in an unexpected shape" do
    let(:fixture) { "foo,bar\nbat,man" }

    it "raises an error" do
      expect { importer.parse! }.to raise_error described_class::Errors::WrongHeaders
    end
  end

  it "calls the mapper with the right arguments" do
    expect(importer.parse!).to eq :result
  end
end
