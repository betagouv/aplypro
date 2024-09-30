# frozen_string_literal: true

require "rails_helper"

RSpec.describe Student do
  subject(:student) { create(:student) }

  let(:schooling_end_date) { "#{SchoolYear.current.start_year}-10-27" }

  it { is_expected.to have_many(:classes).through(:schoolings) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:birthdate) }
  it { is_expected.to validate_presence_of(:ine) }
  it { is_expected.to validate_uniqueness_of(:asp_file_reference) }

  describe "biological_sex" do
    it "can be unknown" do
      expect(build(:student, biological_sex: nil)).to be_valid
    end

    it "cannot be a random value" do
      expect(build(:student, biological_sex: 3)).not_to be_valid
    end
  end

  describe "asp_file_reference" do
    subject(:student) { build(:student, asp_file_reference: nil) }

    it "is generated before_save" do
      expect { student.save! }.to change(student, :asp_file_reference)
    end

    # rubocop:disable RSpec/SubjectStub
    context "when there is a collision" do
      let(:used_values) { %w[A B C] }

      before do
        used_values.each { |value| create(:student, asp_file_reference: value) }

        allow(student)
          .to receive(:generate_asp_file_reference)
          .and_return(*used_values, "D")
      end

      it "tries until it is unique" do
        student.save!

        expect(student)
          .to have_received(:generate_asp_file_reference)
          .exactly(4).times
      end
    end
    # rubocop:enable RSpec/SubjectStub
  end

  describe "current_schooling" do
    subject(:current_schooling) { student.reload.current_schooling }

    let!(:schooling) { create(:schooling, student: student) }

    it { is_expected.to eq schooling }

    context "when it is closed" do
      before { schooling.update!(end_date: Date.yesterday) }

      it { is_expected.to be_nil }
    end

    it "is always unique" do
      expect { create(:schooling, student: student) }.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe "close_current_schooling!" do
    let!(:schooling) { create(:schooling, student: student) }

    it "removes the current schooling" do
      expect { student.close_current_schooling!(Date.yesterday) }
        .to change { student.reload.current_schooling }.from(schooling).to(nil)
    end

    it "sets the end date" do
      expect { student.reload.close_current_schooling!(schooling_end_date) }.to(change { schooling.reload.end_date })
    end

    it "can use a specific end date" do
      datetime = schooling_end_date

      expect { student.close_current_schooling!(datetime) }
        .to(change { schooling.reload.end_date }.to(datetime.to_date))
    end

    context "when there is no current schooling" do
      before { student.close_current_schooling!(schooling_end_date) }

      it "does not crash" do
        expect { student.close_current_schooling!(schooling_end_date) }.not_to raise_error
      end
    end
  end

  describe "without_ribs" do
    let(:students) { create_list(:student, 3) }

    before { students.first(2).each { |student| create(:rib, student: student) } }

    it "returns only the students without ribs" do
      expect(described_class.without_ribs).to contain_exactly students.last
    end
  end

  describe "with_valid_address_city" do
    subject { described_class.with_valid_address_city }

    context "when the student is born in France" do
      let(:student) { create(:student, :with_french_address) }

      context "when their address city code is nil" do
        before { student.update!(address_city_insee_code: nil) }

        it { is_expected.not_to include student }
      end

      context "when their address city code is not nil" do
        it { is_expected.to include student }
      end
    end

    context "when the student is foreign" do
      let(:student) { create(:student, :with_foreign_address) }

      context "when they have no city code" do
        before { student.update!(address_city_insee_code: nil) }

        it { is_expected.to include student }
      end

      context "when they have a city code" do
        before { student.update!(address_city_insee_code: "34000") }

        it { is_expected.to include student }
      end
    end
  end

  describe "adult?" do
    before { student.update(birthdate: 18.years.ago) }

    context "when the student is an adult" do
      it { expect(student.adult_at?(Time.zone.today)).to be true }
    end

    context "when the student is not an adult" do
      it { expect(student.adult_at?(Time.zone.today - 1.day)).to be false }
    end
  end

  describe "transferred?" do
    subject { student.transferred? }

    let(:establishment) { create(:establishment) }
    let(:mef) { create(:mef) }

    before { create(:schooling, student: student) }

    context "when the student has two classes" do
      before { create(:schooling, :closed, student: student) }

      context "with different MEFs" do
        before do
          student.classes.each { |classe| classe.update!(mef: create(:mef)) }
        end

        context "with the same establishment" do
          before do
            student.classes.each { |classe| classe.update!(establishment: establishment) }
          end

          it { is_expected.to be true }
        end

        context "with different establishments" do
          before do
            student.classes.each { |classe| classe.update!(establishment: create(:establishment)) }
          end

          it { is_expected.to be true }
        end
      end

      context "with the same MEFs" do
        before do
          student.classes.each { |classe| classe.update!(mef: mef) }
        end

        context "with the same establishment" do
          before do
            student.classes.each { |classe| classe.update!(establishment: establishment) }
          end

          it { is_expected.to be false }
        end

        context "with different establishments" do
          before do
            student.classes.each { |classe| classe.update!(establishment: create(:establishment)) }
          end

          it { is_expected.to be true }
        end
      end
    end
  end

  describe "#create_new_rib" do
    let(:previous_rib) { create(:rib) }

    context "when a new rib is created" do
      context "when the precedent rib can be archived" do
        it "archives the precedent rib" do
          expect do
            previous_rib.student.create_new_rib(build(:rib, student: previous_rib.student).attributes)
          end.to change { previous_rib.reload.archived? }.from(false).to(true)
        end
      end

      context "when the precedent rib cannot be archived" do
        let(:previous_rib) { create(:asp_payment_request, :ready).rib }

        it "errors on save" do
          expect do
            previous_rib.student.create_new_rib(build(:rib, student: previous_rib.student).attributes).save!
          end.to raise_error ActiveRecord::RecordInvalid
        end
      end
    end
  end
end
