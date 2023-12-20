# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a student mapper" do
  subject(:mapper) { described_class.new(data, uai) }

  context "with a normal payload" do
    let(:data) { normal_payload }

    [Student, Schooling, Classe].each do |model|
      it "changes the #{model} count" do
        expect { mapper.parse! }.to change(model, :count)
      end

      it "upserts the #{model}" do
        mapper.parse!

        expect { mapper.parse! }.not_to change(model, :count)
      end
    end

    context "when the payload is the same" do
      before { mapper.parse! }

      it "does not change the active schoolings" do
        expect { mapper.parse! }.not_to change(Schooling.current, :count)
      end
    end
  end

  context "with a payload that contains students without INEs" do
    let(:data) { nil_ine_payload }

    it "doesn't crash on students without an INE" do
      expect { described_class.new(nil_ine_payload, uai).parse! }.not_to raise_error
    end
  end

  context "when the payload contains irrelevant mefs" do
    let(:data) { irrelevant_mefs_payload }

    [Student, Schooling, Classe].each do |model|
      it "does not change the #{model} count" do
        expect { mapper.parse! }.not_to change(model, :count)
      end
    end
  end

  context "when the student mapping crashes" do
    let(:data) { faulty_student_payload }

    it "catches the error" do
      expect { mapper.parse! }.not_to raise_error
    end

    it "parses all the other students" do
      expect { mapper.parse! }.to change(Schooling, :count).by(data.length - 1)
    end
  end

  context "when the classe mapping crashes" do
    let(:data) { faulty_classe_payload }

    it "catches the error" do
      expect { mapper.parse! }.not_to raise_error
    end

    it "parses all the other classes" do
      expect { mapper.parse! }.to change(Classe, :count)
    end
  end

  context "when the payload is empty" do
    let(:data) { [] }

    it "doesn't crash" do
      expect { mapper.parse! }.not_to raise_error
    end
  end

  context "when a student is received in a new establishment" do
    let(:data) { normal_payload }
    let(:student) { Student.first }
    let(:new_mapper) { described_class.new(data, create(:establishment).uai) }

    before do
      mapper.parse!
    end

    it "creates a new active schooling" do
      expect { new_mapper.parse! }.to(change { student.reload.current_schooling })
    end
  end
end
