# frozen_string_literal: true

require "rails_helper"
require "support/webmock_helpers"

RSpec.describe GenerateAttributiveDecisionsJob do
  subject(:job) { described_class.new(establishment) }

  let(:establishment) { create(:establishment, :with_fim_user) }
  let(:classes) { create_list(:classe, 2, :with_students, students_count: 3, establishment: establishment) }
  let(:students) { classes.flat_map(&:students) }
  let(:schooling) { students.last.current_schooling }

  context "when there are no attributive decisions" do
    it "generates one for each student" do
      expect { job.perform_now }.to have_enqueued_job(GenerateAttributiveDecisionJob).exactly(students.count)
    end

    it "toggles the generating attribute on each schooling" do
      expect { job.perform_now }.to change { schooling.reload.generating_attributive_decision }.from(false).to(true)
    end
  end

  context "when some attributive decisions are already generated" do
    before { schooling.attach_attributive_document(StringIO.new("hello"), :attributive_decision) }

    it "does not enqueue a job for it" do
      expect { job.perform_now }.not_to have_enqueued_job.with(schooling)
    end
  end

  context "when a student is inactive" do
    before { schooling.update!(end_date: Time.zone.today) }

    it "enqueues a job for it anyway" do
      expect { job.perform_now }.to have_enqueued_job.with(schooling)
    end
  end
end
