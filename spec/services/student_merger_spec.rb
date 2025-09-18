# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentMerger do
  describe "#merge!" do
    let(:source_student) { create(:student) }
    let(:target_student) { create(:student) }
    let(:students) { [source_student, target_student] }
    let(:merger) { described_class.new(students) }

    context "when students are not identical" do
      before do
        target_student.update!(
          first_name: "#{source_student.first_name}XXXX"
        )
      end

      it "raises an error" do
        merger = described_class.new([source_student, target_student])
        expect { merger.merge! }.to raise_error(StudentMerger::StudentNotIdenticalError)
      end
    end

    context "when students are identical" do
      before do
        source_student.update!(birthplace_city_insee_code: Faker::Number.number(digits: 5))
        target_student.update!(
          first_name: source_student.first_name,
          last_name: source_student.last_name,
          birthdate: source_student.birthdate,
          birthplace_city_insee_code: source_student.birthplace_city_insee_code
        )
      end

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
          expect { merger.merge! }.to raise_error(StudentMerger::BothActiveSchoolingsError)
        end
      end

      context "when transferring asp_individu_id" do
        before do
          source_student.update!(asp_individu_id: "123ABC")
          target_student.update!(asp_individu_id: nil)
        end

        it "transfers asp_individu_id from source to target student" do
          merger.merge!

          expect(target_student.reload.asp_individu_id).to eq("123ABC")
        end
      end

      context "when transferring ribs" do
        let(:rib) { create(:rib, student: source_student) }

        it "transfers ribs from source to target student" do
          expect(rib.student).to eq source_student
          merger.merge!

          expect(rib.reload.student).to eq target_student
          expect(rib.reload).to be_archived
        end
      end
    end
  end
end
