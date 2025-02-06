# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentMerger do
  describe "#merge!" do
    let(:student1) { create(:schooling, :closed).student }
    let(:student2) { create(:schooling, :closed).student }
    let(:students) { [student1, student2] }
    let(:merger) { described_class.new(students) }

    context "with invalid inputs" do
      it "raises error when not given exactly two students" do
        merger = described_class.new([student1])
        expect { merger.merge! }.to raise_error(StudentMerger::InvalidStudentsArrayError)
      end
    end

    context "when merging students with payment requests" do
      let(:older_payment_request) { create(:asp_payment_request, created_at: 1.month.ago) }
      let(:newer_payment_request) { create(:asp_payment_request, created_at: 1.day.ago) }
      let(:student1) { older_payment_request.student }
      let(:student2) { newer_payment_request.student }

      before do
        student1.current_schooling.update!(end_date: 2.days.ago)
      end

      it "keeps the student with the most recent payment request" do
        merger.merge!
        expect(Student.exists?(student1.id)).to be false
        expect(Student.exists?(student2.id)).to be true
      end

      it "raises error when trying to transfer active schoolings" do
        create(:schooling, student: student1)
        expect { merger.merge! }.to raise_error(StudentMerger::ActiveSchoolingError)
      end
    end
  end
end
