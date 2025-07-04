# frozen_string_literal: true

require "rails_helper"

describe ASP::AttachDocument do
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

      it "purges the existing attachment before attaching a new one" do
        schooling.attributive_decision.attach(
          io: StringIO.new("existing attachment"),
          filename: "existing.pdf",
          content_type: "application/pdf"
        )
        expect do
          described_class.from_schooling(output, schooling, :attributive_decision)
        end.to(change { schooling.attributive_decision.attachment.blob.id })
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
