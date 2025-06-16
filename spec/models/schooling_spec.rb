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

  describe "scopes" do
    let!(:current_schooling_no_end_date) { create(:schooling, end_date: nil) }
    let!(:current_schooling_future_end_date) { create(:schooling, end_date: 1.day.from_now) }
    let!(:former_schooling_past_end_date) { create(:schooling, end_date: 1.day.ago) }

    describe ".former" do
      subject { described_class.former }

      it { is_expected.to include(former_schooling_past_end_date) }
      it { is_expected.not_to include(current_schooling_no_end_date) }
      it { is_expected.not_to include(current_schooling_future_end_date) }

      it "includes schoolings with end_date on or before the current date" do
        expect(described_class.former.to_a).to eq([former_schooling_past_end_date])
      end
    end

    describe ".current" do
      subject { described_class.current }

      it { is_expected.to include(current_schooling_no_end_date) }
      it { is_expected.to include(current_schooling_future_end_date) }
      it { is_expected.not_to include(former_schooling_past_end_date) }

      it "includes schoolings with no end_date or end_date after the current date" do
        expect(described_class.current.to_a).to contain_exactly(current_schooling_no_end_date,
                                                                current_schooling_future_end_date)
      end
    end

    describe "mutual exclusivity" do
      it "ensures every schooling is either current or former" do
        all_schoolings = described_class.all
        current_and_former = described_class.current.or(described_class.former)

        expect(all_schoolings).to match_array(current_and_former)
      end

      it "ensures no schooling is both current and former" do
        overlap = described_class.current.where(id: described_class.former)

        expect(overlap).to be_empty
      end
    end
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

    describe "extended_end_date" do
      context "when end_date is present" do
        before do
          schooling.end_date = Date.current
        end

        it "is invalid when extended_end_date is before end_date" do
          schooling.extended_end_date = schooling.end_date - 1.day
          expect(schooling).not_to be_valid
        end

        it "is valid when extended_end_date is on or after end_date" do
          schooling.extended_end_date = schooling.end_date + 1.day
          expect(schooling).to be_valid
        end
      end
    end

    describe ".for_year" do
      before { schooling.update!(classe: classe, start_date: Date.parse("2020-09-01")) }

      let(:school_year) { create(:school_year, start_year: 2020) }
      let(:classe) { create(:classe, school_year: school_year) }

      it "returns the schoolings of the current school year" do
        expect(described_class.for_year(2020)).to contain_exactly(schooling)
      end
    end

    describe "student_id" do
      context "when there is another schooling" do
        let!(:schooling) { create(:schooling) }

        context "with an end date" do
          before { schooling.student.close_current_schooling!("#{SchoolYear.current.end_year}-08-27") }

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
    it { is_expected.to include SchoolYear.current.start_year.to_s }
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
      schooling.student.update!(first_name: "Jeanne", last_name: "DUPONT")
    end

    it "creates a sane filename" do
      year = SchoolYear.current.start_year
      decision_number = schooling.attributive_decision_number
      key =
        "#{uai}/#{year}/1ere-apex-test/DUPONT_Jeanne_décision-d-attribution_#{decision_number}.pdf"

      expect(schooling.attributive_decision_key(schooling.attachment_file_name("décision-d-attribution"))).to eq key
    end
  end

  describe "#closed?" do
    subject(:schooling) { create(:schooling, end_date: Date.tomorrow) }

    it "returns false" do
      expect(schooling.closed?).to be false
    end

    context "when the schooling is closed in the past" do
      subject(:schooling) { create(:schooling, end_date: Date.yesterday) }

      it "returns true" do
        expect(schooling.closed?).to be true
      end
    end
  end

  describe "#syncable?" do
    let(:schooling) { create(:schooling) }
    let(:establishment) { schooling.establishment }
    let(:student) { schooling.student }

    context "when student has ine" do
      before { student.update!(ine_not_found: false) }

      it { expect(schooling).to be_syncable }
    end

    context "when schooling is not removed" do
      before { schooling.update!(removed_at: nil) }

      it { expect(schooling).to be_syncable }
    end

    context "when establishment has a students_provider" do
      before { establishment.update!(students_provider: "sygne") }

      it { expect(schooling).to be_syncable }
    end

    context "when none of the conditions are not met" do
      before do
        student.update!(ine_not_found: true)
        schooling.update!(removed_at: nil)
        establishment.update!(students_provider: "sygne")
      end

      it { expect(schooling).not_to be_syncable }
    end
  end

  describe ".former" do
    subject { described_class.former }

    context "when the schooling is over" do
      let(:schooling) { create(:schooling, :closed) }

      it { is_expected.to include schooling }
    end

    context "when the schooling has an end_date in the future" do
      let(:schooling) { create(:schooling, start_date: Date.yesterday, end_date: Date.tomorrow) }

      it { is_expected.not_to include schooling }
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

    it "forwards its UAI, MEF code and school year to Exclusion.excluded?" do
      schooling.excluded?

      expect(Exclusion).to have_received(:excluded?).with(schooling.establishment.uai,
                                                          schooling.mef.code,
                                                          schooling.classe.school_year)
    end

    it "returns the result" do
      expect(schooling.excluded?).to eq "a fake result"
    end
  end

  describe "removed?" do
    it "returns false" do
      expect(schooling.removed?).to be false
    end

    it "returns true" do
      schooling.removed_at = Time.zone.today
      expect(schooling.removed?).to be true
    end
  end

  describe "#max_end_date" do
    let(:schooling) { create(:schooling) }

    context "when extended_end_date is present" do
      it "returns the extended_end_date" do
        schooling.end_date = Date.new(2023, 6, 30)
        schooling.extended_end_date = Date.new(2023, 7, 31)
        expect(schooling.max_end_date).to eq(Date.new(2023, 7, 31))
      end
    end

    context "when extended_end_date is nil" do
      it "returns the end_date" do
        schooling.end_date = Date.new(2023, 6, 30)
        schooling.extended_end_date = nil
        expect(schooling.max_end_date).to eq(Date.new(2023, 6, 30))
      end
    end

    context "when both extended_end_date and end_date are nil" do
      it "returns nil" do
        schooling.end_date = nil
        schooling.extended_end_date = nil
        expect(schooling.max_end_date).to be_nil
      end
    end
  end

  describe "#attach_attributive_document" do
    let(:schooling) { create(:schooling) }
    let(:output) { StringIO.new("test output") }

    context "with a valid attachment type" do
      it "attaches the attributive decision" do
        expect do
          schooling.attach_attributive_document(output, :attributive_decision)
        end.to change { schooling.attributive_decision.attached? }.from(false).to(true)

        expect(schooling.attributive_decision.filename.to_s).to match(/d\u00E9cision-d-attribution/)
        expect(schooling.attributive_decision.content_type).to eq("application/pdf")
      end

      it "attaches the abrogation decision" do
        expect do
          schooling.attach_attributive_document(output, :abrogation_decision)
        end.to change { schooling.abrogation_decision.attached? }.from(false).to(true)

        expect(schooling.abrogation_decision.filename.to_s).to match(/d\u00E9cision-d-abrogation/)
        expect(schooling.abrogation_decision.content_type).to eq("application/pdf")
      end

      it "attaches the cancellation decision" do
        expect do
          schooling.attach_attributive_document(output, :cancellation_decision)
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

  describe "#nullified?" do
    context "when schooling is abrogated" do
      let(:schooling) { create(:schooling, :closed, :with_abrogation_decision) }

      it "returns true" do
        expect(schooling.nullified?).to be true
      end
    end

    context "when schooling is cancelled" do
      let(:schooling) { create(:schooling) }

      before do
        schooling.cancellation_decision.attach(
          io: StringIO.new("cancellation document"),
          filename: "cancellation.pdf",
          content_type: "application/pdf"
        )
      end

      it "returns true" do
        expect(schooling.nullified?).to be true
      end
    end

    context "when schooling is neither abrogated nor cancelled" do
      let(:schooling) { create(:schooling) }

      it "returns false" do
        expect(schooling.nullified?).to be false
      end
    end
  end

  describe "#abrogated?" do
    context "when schooling is closed with abrogation decision attached" do
      let(:schooling) { create(:schooling, :closed, :with_abrogation_decision) }

      it "returns true" do
        expect(schooling.abrogated?).to be true
      end
    end

    context "when schooling is closed but without abrogation" do
      let(:schooling) { create(:schooling, :closed) }

      it "returns false" do
        expect(schooling.abrogated?).to be false
      end
    end

    context "when schooling is not closed but has abrogation" do
      let(:schooling) { create(:schooling, :with_abrogation_decision) }

      before do
        schooling.update!(end_date: nil)
      end

      it "returns false" do
        expect(schooling.abrogated?).to be false
      end
    end

    context "when schooling is neither closed nor has abrogation" do
      let(:schooling) { create(:schooling) }

      it "returns false" do
        expect(schooling.abrogated?).to be false
      end
    end
  end

  describe "#cancelled?" do
    context "when schooling has cancellation attached" do
      let(:schooling) { create(:schooling) }

      before do
        schooling.cancellation_decision.attach(
          io: StringIO.new("cancellation document"),
          filename: "cancellation.pdf",
          content_type: "application/pdf"
        )
      end

      it "returns true" do
        expect(schooling.cancelled?).to be true
      end
    end

    context "when schooling does not have cancellation attached" do
      let(:schooling) { create(:schooling) }

      it "returns false" do
        expect(schooling.cancelled?).to be false
      end
    end

    context "when schooling has other decisions but not cancellation" do
      let(:schooling) { create(:schooling, :with_attributive_decision) }

      it "returns false" do
        expect(schooling.cancelled?).to be false
      end
    end
  end
end
