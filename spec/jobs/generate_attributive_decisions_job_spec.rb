# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe GenerateAttributiveDecisionsJob do
  subject(:job) { described_class.new(establishment.schoolings) }

  let(:establishment) { create(:establishment, :with_fim_user) }
  let(:school_year) { SchoolYear.current }
  let(:classes) do
    create_list(:classe, 2, :with_students, students_count: 3, establishment: establishment, school_year: school_year)
  end
  let(:students) { classes.flat_map(&:students) }
  let(:schooling) { students.last.current_schooling }

  context "when there are no attributive decisions" do
    it "generates one for each student" do
      expect { job.perform_now }.to have_enqueued_job(GenerateAttributiveDecisionJob).exactly(students.count)
    end
  end

  context "when a student is inactive" do
    before { schooling.update!(end_date: "#{SchoolYear.current.end_year}-08-27") }

    it "enqueues a job for it anyway" do
      expect { job.perform_now }.to have_enqueued_job.with(schooling)
    end
  end
end
