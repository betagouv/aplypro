# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/api_student"
require "./spec/support/shared/student_mapper"

describe Student::Mappers::Sygne do
  let(:establishment) { create(:establishment, :with_fim_user) }
  let(:normal_payload) { build_list(:sygne_student, 10, classe: "1MELEC") }

  it_behaves_like "a student mapper" do
    let(:irrelevant_mefs_payload) { build_list(:sygne_student, 10, codeMef: "-1") }
    let(:nil_ine_payload) { normal_payload.push(build(:sygne_student, :no_ine)) }
  end

  describe "schoolings reconciliation" do
    subject(:mapper) { described_class.new(next_data, establishment) }

    let(:student) { Student.find_by(ine: normal_payload.last["ine"]) }

    before { described_class.new(normal_payload, establishment).parse! }

    context "when a student has disappeared" do
      let(:next_data) { normal_payload.dup.tap(&:pop) }

      it "closes its current shooling" do
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
  end
end
