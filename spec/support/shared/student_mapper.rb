# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a student mapper" do
  subject(:mapper) { described_class.new(data, establishment) }

  it "upserts the students" do
    expect { mapper.parse! }.to change(Student, :count).by_at_most(data.length)
  end

  it "doesn't duplicate students" do
    mapper.parse!

    expect { mapper.parse! }.not_to change(Student, :count)
  end

  it "doesn't crash on students without an INE" do
    expect { described_class.new(nil_ine_payload, establishment).parse! }.not_to raise_error
  end

  it "doesn't crash on an empty payload" do
    expect { described_class.new(empty_payload, establishment).parse! }.not_to raise_error
  end

  it "upserts the classes" do
    expect { mapper.parse! }.to change(Classe, :count)
  end

  it "creates schoolings" do
    expect { mapper.parse! }.to change(Schooling, :count).by_at_most(data.length)
  end

  it "marks the schoolings as current" do
    mapper.parse!

    Student.find_each do |student|
      expect(student.current_schooling).not_to be_nil
    end
  end

  describe "student attributes parsing" do
    before { mapper.parse! }

    %i[first_name last_name ine birthdate].each do |attr|
      it "parses the '#{attr}' attribute" do
        expect(Student.last[attr]).not_to be_nil
      end
    end
  end

  describe "when some students have already left on the first parse" do
    subject(:mapper) { described_class.new(gone_student_payload, establishment) }

    it "does not crash" do
      expect { mapper.parse! }.not_to raise_error
    end
  end

  describe "when there are irrelevant MEFS" do
    let(:data) { irrelevant_mefs_payload }

    it "skips them" do
      expect { mapper.parse! }.not_to change(Student, :count)
    end
  end

  describe "subsequent updates" do
    let(:student) { Student.find_by(ine: student_ine) }

    before { mapper.parse! }

    describe "when a student has already moved" do
      it "can handle parsing it again" do
        expect do
          described_class.new(gone_student_payload, establishment).parse!
          described_class.new(gone_student_payload, establishment).parse!
        end.not_to raise_error
      end
    end

    describe "when a student is not in a class anymore" do
      let(:new_mapper) { described_class.new(gone_student_payload, establishment) }

      include_examples "student has moved"
    end

    describe "when a student has changed class" do
      let(:new_mapper) { described_class.new(changed_class_student_payload, establishment) }

      include_examples "student has moved"
    end

    describe "when a student has changed establishment" do
      let(:new_establishment) { create(:establishment) }
      let(:new_mapper) { described_class.new(changed_class_student_payload, new_establishment) }

      include_examples "student has moved"
    end
  end
end

RSpec.shared_examples "student has moved" do
  it "removes the current schooling on that student" do
    expect { new_mapper.parse! }.to(change { student.reload.current_schooling })
  end

  it "sets the end date on the old schooling" do
    schooling = student.current_schooling

    expect { new_mapper.parse! }.to change { schooling.reload.end_date }.from(nil).to(Time.zone.today)
  end
end
