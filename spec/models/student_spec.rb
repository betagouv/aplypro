# frozen_string_literal: true

require "rails_helper"

RSpec.describe Student do
  subject(:student) { create(:student) }

  let(:end_date) { "#{SchoolYear.current.end_year}-08-27" }

  it { is_expected.to have_many(:classes).through(:schoolings) }
  it { is_expected.to validate_length_of(:address_city_insee_code).is_at_most(5) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:birthdate) }
  it { is_expected.to validate_presence_of(:ine) }

  describe "#rib" do
    subject(:student) { classe.students.first }

    let(:classe) { create(:classe, :with_students) }

    it "returns nil when the student has no RIBs" do
      expect(student.rib).to be_nil
    end

    context "when the student has RIBs" do
      before do
        create(:rib, student: student, archived_at: 1.day.ago, establishment: classe.establishment)
        create(:rib, student: student, archived_at: nil, establishment: classe.establishment)
      end

      it "returns the active RIB" do
        expect(student.rib).to eq(student.ribs.last)
      end

      context "when an establishment is provided" do
        it "returns the active RIB for the given establishment" do
          expect(student.rib(classe.establishment)).to eq(student.ribs.last)
        end
      end
    end
  end

  describe "biological_sex" do
    it "can be unknown" do
      expect(build(:student, biological_sex: nil)).to be_valid
    end

    it "cannot be a random value" do
      expect(build(:student, biological_sex: 3)).not_to be_valid
    end
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
      expect { student.reload.close_current_schooling!(end_date) }.to(change { schooling.reload.end_date })
    end

    it "can use a specific end date" do
      datetime = end_date

      expect { student.close_current_schooling!(datetime) }
        .to(change { schooling.reload.end_date }.to(datetime.to_date))
    end

    context "when there is no current schooling" do
      before { student.close_current_schooling!(end_date) }

      it "does not crash" do
        expect { student.close_current_schooling!(end_date) }.not_to raise_error
      end
    end
  end

  describe "without_ribs" do
    let(:students) { create(:classe, :with_students, students_count: 3).students }

    before { students.first(2).each { |student| create(:rib, establishment: student.establishment, student: student) } }

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

  describe "#duplicates" do
    let(:student) do
      create(:student,
             first_name: "Jean-Pierre",
             last_name: "N'Dour",
             birthdate: "2000-01-01",
             birthplace_city_insee_code: "75056")
    end

    it "finds students with apostrophes and hyphens replaced by spaces" do
      duplicate = create(:student,
                         first_name: "Jean Pierre",
                         last_name: "N Dour",
                         birthdate: student.birthdate,
                         birthplace_city_insee_code: student.birthplace_city_insee_code)

      expect(student.duplicates).to include(student, duplicate)
    end

    it "handles accents correctly" do
      duplicate = create(:student,
                         first_name: "Jéan-Pièrre",
                         last_name: "N'Doùr",
                         birthdate: student.birthdate,
                         birthplace_city_insee_code: student.birthplace_city_insee_code)

      expect(student.duplicates).to include(duplicate)
    end

    it "does not find students with different birthdate or birthplace" do # rubocop:disable RSpec/ExampleLength
      different_birthdate = create(:student,
                                   first_name: "Jean Pierre",
                                   last_name: "N Dour",
                                   birthdate: "2001-01-01",
                                   birthplace_city_insee_code: student.birthplace_city_insee_code)

      different_birthplace = create(:student,
                                    first_name: "Jean Pierre",
                                    last_name: "N Dour",
                                    birthdate: student.birthdate,
                                    birthplace_city_insee_code: "69123")

      expect(student.duplicates).not_to include(different_birthdate, different_birthplace)
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
    let(:student) { create(:schooling).student }
    let(:previous_rib) { create(:rib, student: student, establishment: student.establishment) }

    context "when a new rib is created" do
      context "when the precedent rib can be archived" do
        it "archives the precedent rib" do
          expect do
            previous_rib.student.create_new_rib(build(:rib, student: previous_rib.student).attributes)
          end.to change { previous_rib.reload.archived? }.from(false).to(true)
        end
      end
    end
  end
end
