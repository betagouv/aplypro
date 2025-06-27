# frozen_string_literal: true

require "rails_helper"

require "./mock/apis/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Sygne do
  let(:uai) { create(:establishment, :sygne_provider).uai }
  let(:normal_payload) { build_list(:sygne_student, 10, classe: "1MELEC") }

  it_behaves_like "a student mapper" do
    let(:irrelevant_mefs_payload) { build_list(:sygne_student, 10, :irrelevant) }
    let(:nil_ine_payload) { normal_payload.push(build(:sygne_student, :no_ine)) }

    let(:faulty_student_payload) do
      normal_payload.tap { |entries| entries.sample.except!("codeMefRatt") }
    end

    let(:faulty_classe_payload) do
      normal_payload.tap { |entries| entries.sample.except!("classe") }
    end
  end

  describe "schoolings reconciliation" do
    subject(:mapper) { described_class.new(next_data, uai) }

    let(:student) { Student.find_by(ine: normal_payload.last["ine"]) }

    before { described_class.new(normal_payload, uai).parse! }

    context "when a student has disappeared" do
      let(:next_data) { normal_payload.dup.tap(&:pop) }

      it "closes its current schooling" do
        expect { mapper.parse! }.to change { student.reload.current_schooling }.to(nil)
      end
    end

    context "when a student is in a new class" do
      let(:next_data) do
        normal_payload.dup.tap do |students|
          students.last["classe"] = "some new class"
        end
      end

      it "closes its previous schoolings" do
        expect { mapper.parse! }.to(change { student.reload.current_schooling })
      end

      it "creates a new one" do
        mapper.parse!

        expect(student.current_schooling.classe.label).to eq "some new class"
      end
    end

    context "when there is a schooling for that classe that was closed" do
      let(:closed_payload) { [build(:sygne_student, :closed, classe: "1MELEC", ine: "1234")] }
      let(:mapper) { described_class.new(closed_payload, uai) }

      let(:student) { Student.find_by(ine: "1234") }

      it "sets the end_date for closed schoolings" do
        mapper.parse!

        expect(student.schoolings.last.end_date.to_s).to eq closed_payload.last["dateFinSco"]
      end

      it "reopens the schooling" do
        opened_payload = [build(:sygne_student, classe: "1MELEC", ine: "1234")]
        opened_mapper = described_class.new(opened_payload, uai)
        opened_mapper.parse!

        expect(student.schoolings.last.open?).to be true
      end

      context "when the schooling is not in the current school year" do
        before { closed_payload.first.update(dateDebSco: "#{SchoolYear.current.start_year - 2}-05-05") }

        it "does not update the end date" do
          mapper.parse!

          expect(student.schoolings.last.end_date).to be_nil
        end
      end
    end

    context "when the student already has a removed schooling" do
      let(:next_data) { normal_payload.dup.tap(&:pop) }

      let(:student) { Student.find_by(ine: normal_payload.last["ine"]) }
      let(:removed_schooling) { create(:schooling, removed_at: Time.zone.today) }

      before do
        student.schoolings << removed_schooling
      end

      it "initializes the incoming schooling" do
        expect { mapper.parse! }.to(change { student.reload.current_schooling })
      end
    end
  end
end
