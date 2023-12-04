# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe GenerateMissingAttributiveDecisionsJob do
  subject(:job) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_fim_user) }
  let(:classes) { create_list(:classe, 2, :with_students, students_count: 3, establishment: establishment) }
  let(:students) { classes.flat_map(&:students) }
  let(:schooling) { students.last.current_schooling }

  before do
    ActiveJob::Base.queue_adapter = :test
    WebmockHelpers.mock_sygne_token_with

    students.each do |student|
      WebmockHelpers.mock_sygne_student_endpoint_with(student.ine, build(:sygne_student, ine: student.ine).to_json)
    end
  end

  context "when there are no attributive decisions" do
    before { allow(GenerateAttributiveDecisionJob).to receive(:perform_now) }

    it "generates one for each student" do
      pending "doing benchmarks"

      job.perform_now

      expect(GenerateAttributiveDecisionJob).to have_received(:perform_now).exactly(students.count)
    end
  end

  context "when some attributive decisions are already generated" do
    before { schooling.rattach_attributive_decision!(StringIO.new("hello")) }

    it "does not enqueue a job for it" do
      expect { job.perform_now }.not_to have_enqueued_job.with(schooling)
    end
  end

  context "when a student is inactive" do
    before { schooling.update!(end_date: Time.zone.today) }

    it "does not enqueue a job for it" do
      expect { job.perform_now }.not_to have_enqueued_job.with(schooling)
    end
  end
end
