# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "closes the current schooling" do
  it "closes the student's previous schooling" do
    expect { next_mapper.parse! }.to(change { student.reload.current_schooling })
  end

  it "sets the end date on the previous schooling" do
    expect { next_mapper.parse! }.to(change { student.schoolings.first.end_date })
  end
end

RSpec.shared_examples "a student mapper" do
  subject(:mapper) { described_class.new(data, establishment) }

  context "with a normal payload" do
    let(:data) { normal_payload }

    it "upserts the students" do
      expect { 2.times { mapper.parse! } }.to change(Student, :count).by(data.length)
    end

    it "upserts the schoolings" do
      expect { 2.times { mapper.parse! } }.to change(Schooling.current, :count).by(data.length)
    end

    it "upserts the classes" do
      expect { 2.times { mapper.parse! } }.to change(Classe, :count).by_at_most(data.length)
    end
  end

  context "with a payload that contains students without INEs" do
    let(:data) { nil_ine_payload }

    it "doesn't crash on students without an INE" do
      expect { described_class.new(nil_ine_payload, establishment).parse! }.not_to raise_error
    end
  end

  context "when the payload is empty" do
    let(:data) { [] }

    it "doesn't crash" do
      expect { mapper.parse! }.not_to raise_error
    end

    context "when there are students in the establishments" do
      before { described_class.new(normal_payload, establishment).parse! }

      it "doesn't aggressively clean previous schoolings" do
        expect { mapper.parse! }.not_to change(Schooling.current, :count)
      end
    end
  end

  describe "updates" do
    subject(:next_mapper) { described_class.new(next_data, establishment) }

    let(:data) { normal_payload }
    let(:next_data) { update_payload }

    before { mapper.parse! }

    context "when a student has changed class" do
      let(:next_data) { last_student_has_changed_class_payload }
      let(:student) { Student.find_by(ine: last_ine) }

      include_examples "closes the current schooling"
    end

    context "when a student has left the establishment" do
      let(:next_data) { last_student_has_left_establishment_payload }
      let(:student) { Student.find_by(ine: last_ine) }

      include_examples "closes the current schooling"
    end
  end
end
