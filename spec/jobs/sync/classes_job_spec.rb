# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sync::ClassesJob do
  include ActiveJob::TestHelper

  let(:establishment) { create(:establishment, :sygne_provider) }
  let(:api_double) { class_double(StudentsApi::Sygne::Api) }
  let(:mapper_double) { instance_double(Student::Mappers::Sygne) }

  before do
    allow(StudentsApi).to receive(:api_for).with("sygne").and_return(api_double)

    allow(api_double).to receive(:fetch_resource).with(:establishment_students, uai: establishment.uai)
    allow(api_double)
      .to receive(:mapper)
      .and_return(class_double(Student::Mappers::Sygne, new: mapper_double))

    allow(mapper_double).to receive(:parse!)
  end

  it "calls the matchingStudentsApi proxy" do
    described_class.perform_now(establishment)

    expect(StudentsApi).to have_received(:api_for).with("sygne")
  end

  it "maps and parse the results" do
    described_class.perform_now(establishment)

    expect(mapper_double).to have_received(:parse!)
  end

  context "when the underlying API fails" do
    before do
      allow(api_double).to receive(:fetch_resource).and_raise(Faraday::UnauthorizedError)
    end

    it "rescues and retry" do
      perform_enqueued_jobs do
        described_class.perform_now(establishment)
      rescue Faraday::UnauthorizedError # rubocop:disable Lint/SuppressedException
      end

      expect(api_double).to have_received(:fetch_resource).exactly(10).times
    end
  end

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  context "when the student's marital status has changed" do
    let(:classe) { create(:classe, establishment: establishment) }
    let(:schooling) { create(:schooling, student: student, classe: classe) }
    let(:student) { create(:student, ine: "007", first_name: "Marie", last_name: "Curie") }

    before do
      described_class.perform_now(establishment)
      build(:sygne_student, ine_value: "007", first_name: "Mario", last_name: "Curio", schooling: schooling)
    end

    it "maps and updates the first name" do
      expect { described_class.perform_now(establishment) }
        .to change { student.attributes.slice("first_name", "last_name") }
        .from("first_name" => "Marie", "last_name" => "Curie")
        .to("first_name" => "Mario", "last_name" => "Curio")
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
