# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentMerger do
  describe "#merge!" do
    let(:source_student) { create(:schooling, :closed).student }
    let(:target_student) { create(:schooling, :closed).student }
    let(:students) { [source_student, target_student] }
    let(:merger) { described_class.new(students) }

    context "with invalid inputs" do
      it "raises error when not given exactly two students" do
        merger = described_class.new([source_student])
        expect { merger.merge! }.to raise_error(StudentMerger::InvalidStudentsArrayError)
      end
    end

    context "when merging students with payment requests" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:older_payment_request) { create(:asp_payment_request, created_at: 1.month.ago) }
      let(:newer_payment_request) { create(:asp_payment_request, created_at: 1.day.ago) }
      let(:source_student) { older_payment_request.student }
      let(:target_student) { newer_payment_request.student }

      before do
        source_student.current_schooling.update!(end_date: 2.days.ago)
      end

      it "keeps the student with the most recent payment request" do
        merger.merge!
        expect(Student.exists?(source_student.id)).to be false
      end

      it "raises error when trying to transfer active schoolings" do
        create(:schooling, student: source_student)
        expect { merger.merge! }.to raise_error(StudentMerger::ActiveSchoolingError)
      end
    end
  end
end
