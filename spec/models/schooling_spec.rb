# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schooling do
  subject(:schooling) { create(:schooling) }

  describe "associations" do
    it { is_expected.to belong_to(:student).class_name("Student") }
    it { is_expected.to belong_to(:classe).class_name("Classe") }
    it { is_expected.to have_many(:pfmps).class_name("Pfmp").order(created_at: :asc) }
    it { is_expected.to have_one(:mef).class_name("Mef") }
  end

  describe "validations" do
    describe "end_date" do
      context "when the end date is before the start" do
        before do
          schooling.start_date = Time.zone.now
          schooling.end_date = Date.yesterday
        end

        it { is_expected.not_to be_valid }
      end
    end

    describe "student_id" do
      context "when there is another schooling" do
        let!(:schooling) { create(:schooling) }

        context "with an end date" do
          before { schooling.student.close_current_schooling! }

          it "can create a new one" do
            expect { create(:schooling, student: schooling.student) }.to change(described_class, :count).by(1)
          end
        end

        context "without an end date" do
          it "rejects the new one" do
            expect { create(:schooling, student: schooling.student) }.to raise_error(ActiveRecord::RecordInvalid)
          end

          it "doesn't reject a closed schooling" do
            expect { create(:schooling, :closed, student: schooling.student) }.to(change(described_class, :count).by(1))
          end
        end
      end
    end
  end

  describe "administrative_number" do
    subject!(:number) { schooling.administrative_number }

    context "when there is already a schooling with that reference" do
      let(:schooling) { build(:schooling) }

      before do
        create(:schooling, administrative_number: "foobar")

        allow(SecureRandom)
          .to receive(:alphanumeric).and_return("FOOBAR").and_return "BATMAN"
      end

      it "creates a new one" do
        expect { schooling.generate_administrative_number }.to change(schooling, :administrative_number).to("BATMAN")
      end
    end
  end

  describe "attributive_decision_bop_indicator" do
    subject(:indicator) { schooling.attributive_decision_number }

    context "when the MEF is from the MENJ" do
      context "when the establishment is private" do
        before { allow(schooling.mef).to receive(:bop).and_return :menj_private }

        it { is_expected.to start_with "ENPR" }
      end

      context "when the establishment is public" do
        before { allow(schooling.mef).to receive(:bop).and_return :menj_public }

        it { is_expected.to start_with "ENPU" }
      end
    end

    context "when the MEF is from the MASA" do
      before { allow(schooling.mef).to receive(:bop).and_return :masa }

      it { is_expected.to start_with "MASA" }
    end
  end

  describe "attributive_decision_number" do
    subject(:number) { schooling.attributive_decision_number }

    let(:schooling) { create(:schooling, :with_attributive_decision) }

    it { is_expected.to include schooling.administrative_number }
    it { is_expected.to include Aplypro::SCHOOL_YEAR.to_s }
    it { is_expected.to include schooling.attributive_decision_bop_indicator.upcase }
  end

  describe "attributive_decision_version" do
    let(:schooling) { create(:schooling) }

    it "defaults to 0" do
      expect(schooling.attributive_decision_version).to eq 0
    end
  end

  describe "attributive_decision_key" do
    let(:schooling) { create(:schooling) }
    let(:uai) { schooling.establishment.uai }

    before do
      schooling.classe.update!(label: "1ERE APEX TEST")
      schooling.student.update!(first_name: "Jeanne", last_name: "DUPONT", asp_file_reference: "ref123")
    end

    it "creates a sane filename" do
      key =
        "#{uai}/2023/1ere-apex-test/DUPONT_Jeanne_décision-d-attribution_#{schooling.attributive_decision_number}.pdf"

      expect(schooling.attributive_decision_key(schooling.attachment_file_name("décision-d-attribution"))).to eq key
    end
  end

  describe ".current" do
    subject { described_class.current }

    context "when the schooling is over" do
      let(:schooling) { create(:schooling, :closed) }

      it { is_expected.not_to include schooling }
    end

    context "when the schooling is active" do
      let(:schooling) { create(:schooling) }

      it { is_expected.to include schooling }
    end
  end

  describe ".former" do
    subject { described_class.former }

    context "when the schooling is over" do
      let(:schooling) { create(:schooling, :closed) }

      it { is_expected.to include schooling }
    end

    context "when the schooling is active" do
      let(:schooling) { create(:schooling) }

      it { is_expected.not_to include schooling }
    end
  end

  describe "#reopen!" do
    let(:schooling) { create(:schooling, :closed) }

    it "resets the end date" do
      expect { schooling.reopen! }.to change(schooling, :open?).from(false).to(true)
    end
  end

  describe "with_attributive_decisions" do
    subject { described_class.with_attributive_decisions }

    let(:schooling) { create(:schooling) }

    context "when the schooling does not have an attached attributive decision" do
      it { is_expected.not_to include(schooling) }
    end

    context "when the schooling has an attached attributive decision" do
      let(:schooling) { create(:schooling, :with_attributive_decision) }

      it { is_expected.to include(schooling) }
    end
  end

  describe "excluded?" do
    before do
      allow(Exclusion).to receive(:excluded?).and_return "a fake result"
    end

    it "forwards its UAI and MEF code to Exclusion.excluded?" do
      schooling.excluded?

      expect(Exclusion).to have_received(:excluded?).with(schooling.establishment.uai, schooling.mef.code)
    end

    it "returns the result" do
      expect(schooling.excluded?).to eq "a fake result"
    end
  end

  describe "#attach_attributive_document" do
    let(:schooling) { create(:schooling) }
    let(:output) { StringIO.new("test output") }

    context "with a valid attachment type" do
      it "attaches the attributive decision" do # rubocop:disable RSpec/MultipleExpectations
        expect do
          schooling.attach_attributive_document(output, :attributive_decision)
        end.to change { schooling.attributive_decision.attached? }.from(false).to(true)

        expect(schooling.attributive_decision.filename.to_s).to match(/d\u00E9cision-d-attribution/)
        expect(schooling.attributive_decision.content_type).to eq("application/pdf")
      end

      it "attaches the abrogation decision" do # rubocop:disable RSpec/MultipleExpectations
        expect do
          schooling.attach_attributive_document(output, :abrogation_decision)
        end.to change { schooling.abrogation_decision.attached? }.from(false).to(true)

        expect(schooling.abrogation_decision.filename.to_s).to match(/d\u00E9cision-d-abrogation/)
        expect(schooling.abrogation_decision.content_type).to eq("application/pdf")
      end

      it "purges the existing attachment before attaching a new one" do # rubocop:disable RSpec/ExampleLength
        schooling.attributive_decision.attach(
          io: StringIO.new("existing attachment"),
          filename: "existing.pdf",
          content_type: "application/pdf"
        )
        expect do
          schooling.attach_attributive_document(output, :attributive_decision)
        end.to(change { schooling.attributive_decision.attachment.blob.id })
      end
    end

    context "with an invalid attachment type" do
      it "raises an error" do
        expect do
          schooling.attach_attributive_document(output, :invalid_attachment)
        end.to raise_error("Unsupported attachment type")
      end
    end
  end
end
