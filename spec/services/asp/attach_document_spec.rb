# frozen_string_literal: true

require "rails_helper"

describe ASP::AttachDocument do
  include ActiveJob::TestHelper

  describe "#from_schooling" do
    let(:schooling) { create(:schooling) }
    let(:output) { StringIO.new("test output") }

    context "with a valid attachment type" do
      it "attaches the attributive decision" do
        expect do
          described_class.from_schooling(output, schooling, :attributive_decision)
        end.to change { schooling.attributive_decision.attached? }.from(false).to(true)

        expect(schooling.attributive_decision.filename.to_s).to match(/d\u00E9cision-d-attribution/)
        expect(schooling.attributive_decision.content_type).to eq("application/pdf")
      end

      it "attaches the abrogation decision" do
        expect do
          described_class.from_schooling(output, schooling, :abrogation_decision)
        end.to change { schooling.abrogation_decision.attached? }.from(false).to(true)

        expect(schooling.abrogation_decision.filename.to_s).to match(/d\u00E9cision-d-abrogation/)
        expect(schooling.abrogation_decision.content_type).to eq("application/pdf")
      end

      it "attaches the cancellation decision" do
        expect do
          described_class.from_schooling(output, schooling, :cancellation_decision)
        end.to change { schooling.cancellation_decision.attached? }.from(false).to(true)

        expect(schooling.cancellation_decision.filename.to_s).to match(/d\u00E9cision-de-retrait/)
        expect(schooling.cancellation_decision.content_type).to eq("application/pdf")
      end

    end

    context "when replacing an existing attachment" do
      subject(:replace_document) { described_class.from_schooling(output, schooling, :attributive_decision) }

      let(:previous_blob) { schooling.attributive_decision.blob }

      before do
        described_class.from_schooling(StringIO.new("previous PDF"), schooling, :attributive_decision)
        previous_blob
      end

      it "uses a new storage key even when the filename is unchanged" do
        replace_document

        expect(schooling.attributive_decision.filename).to eq(previous_blob.filename)
        expect(schooling.attributive_decision.key).not_to eq(previous_blob.key)
        expect(previous_blob.download).to eq("previous PDF")
      end

      it "uploads the replacement before the attachment transaction commits" do
        Schooling.transaction(requires_new: true) do
          replace_document

          expect(schooling.attributive_decision.download).to eq("test output")
        end
      end

      it "preserves the previous PDF when replacement is rolled back" do
        Schooling.transaction(requires_new: true) do
          replace_document
          raise ActiveRecord::Rollback
        end

        expect(schooling.reload.attributive_decision.blob).to eq(previous_blob)
        expect(previous_blob.download).to eq("previous PDF")
        expect(ActiveStorage::PurgeJob).not_to have_been_enqueued.with(previous_blob)
      end

      it "preserves the previous PDF when uploading fails" do
        allow(previous_blob.service).to receive(:upload).and_raise(IOError, "upload failed")

        expect { replace_document }.to raise_error(IOError, "upload failed")

        expect(schooling.reload.attributive_decision.blob).to eq(previous_blob)
        expect(previous_blob.download).to eq("previous PDF")
      end

      it "schedules cleanup only after the attachment transaction commits" do
        expect do
          Schooling.transaction(requires_new: true) do
            replace_document
            expect(ActiveStorage::PurgeJob).not_to have_been_enqueued.with(previous_blob)
          end
        end.to have_enqueued_job(ActiveStorage::PurgeJob).with(previous_blob)
      end

      it "gives existing downloads an hour before cleanup" do
        Timecop.freeze do
          expect { replace_document }
            .to have_enqueued_job(ActiveStorage::PurgeJob).with(previous_blob).at(1.hour.from_now)

          perform_enqueued_jobs(only: ActiveStorage::PurgeJob, at: 59.minutes.from_now)
          expect(previous_blob.download).to eq("previous PDF")
        end
      end

      it "eventually deletes the previous PDF without deleting its replacement" do
        replace_document
        perform_enqueued_jobs(only: ActiveStorage::PurgeJob, at: 2.hours.from_now)

        expect(previous_blob.service.exist?(previous_blob.key)).to be(false)
        expect(schooling.reload.attributive_decision.download).to eq("test output")
      end
    end

    context "with an invalid attachment type" do
      it "raises an error" do
        expect do
          described_class.from_schooling(output, schooling, :invalid_attachment)
        end.to raise_error("Unsupported attachment type")
      end
    end
  end
end
