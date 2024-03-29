# frozen_string_literal: true

require "rails_helper"

RSpec.describe Student do
  subject(:student) { create(:student) }

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
      expect { student.close_current_schooling! }.to change { student.reload.current_schooling }.from(schooling).to(nil)
    end

    it "sets the end date" do
      expect { student.reload.close_current_schooling! }.to(change { schooling.reload.end_date })
    end

    it "can use a specific end date" do
      datetime = 5.days.ago

      expect { student.close_current_schooling!(datetime) }
        .to(change { schooling.reload.end_date }.to(datetime.to_date))
    end

    context "when there is no current schooling" do
      before { student.close_current_schooling! }

      it "does not crash" do
        expect { student.close_current_schooling! }.not_to raise_error
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
end
