# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe GenerateAttributiveDecisionsJob do
  subject(:job) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_fim_user) }
  let(:classes) { create_list(:classe, 2, :with_students, students_count: 3, establishment: establishment) }
  let(:students) { classes.flat_map(&:students) }

  before do
    ActiveJob::Base.queue_adapter = :test
    WebmockHelpers.mock_sygne_token_with

    students.each do |student|
      WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, build(:sygne_student, ine: student.ine).to_json)
    end
  end

  # NOTE: there's the much nicer
  #
  #   expect { job.perform_now }
  #     .to have_enqueued_job(FetchStudentAddressJob)
  #     .exactly(students.count).times
  #
  # but we can't use it because we request the address synchronously
  # hence we use `perform_now` which skips the underlying job queue
  # and prevents queue-based matchers like `have_enqueued_job`. Use
  # the WebMock requests instead.
  it "makes a call per student to get their address" do
    job.perform_now

    expect(a_request(:get, /#{ENV.fetch('APLYPRO_SYGNE_URL')}/)).to have_been_made.times(students.count)
  end

  context "when the students already have addresses" do
    before do
      students.each do |student|
        student.update!(address_line1: "some address")
      end
    end

    it "does not call the api" do
      job.perform_now

      expect(a_request(:get, /#{ENV.fetch('APLYPRO_SYGNE_URL')}/)).not_to have_been_made
    end
  end

  it "generates one attributive decision per student" do
    expect { described_class.perform_now(establishment) }.to change(
      Schooling.joins(:attributive_decision_attachment),
      :count
    ).by(6)
  end

  it "generates an archive with all attributives decisions" do
    expect { job.perform_now }.to change { establishment.attributive_decisions_zip.attached? }.to true
  end

  context "when there are inactive students" do
    let(:generator) { instance_double(AttributeDecisionGenerator, generate!: nil) }
    let(:student) { students.last }

    before do
      student.close_current_schooling!

      allow(AttributeDecisionGenerator).to receive(:new).and_return generator
    end

    it "does not process them" do
      described_class.perform_now(establishment)

      expect(AttributeDecisionGenerator).not_to have_received(:new).with(student.schoolings.first)
    end
  end

  context "when another student with the same name already has an attributive decision" do
    before do
      student = students.first
      same_name_student = create(:student, first_name: student.first_name, last_name: student.last_name)

      create(:schooling, :with_attributive_decision, student: same_name_student)
    end

    it "doesn't fail" do
      expect { described_class.perform_now(establishment) }.not_to raise_error
    end
  end
end
