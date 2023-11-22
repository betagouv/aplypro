# frozen_string_literal: true

require "rails_helper"

require "attribute_decision_generator"

RSpec.describe Schooling do
  describe "associations" do
    it { is_expected.to belong_to(:student).class_name("Student") }
    it { is_expected.to belong_to(:classe).class_name("Classe") }
    it { is_expected.to have_many(:pfmps).class_name("Pfmp") }
    it { is_expected.to have_one(:mef).class_name("Mef") }
  end

  describe "validations" do
    describe "student_id" do
      context "when there is another schooling" do
        let!(:schooling) { create(:schooling) }

        context "with an end date" do
          before { schooling.student.close_current_schooling! }

          it "can create a new one" do
            expect { create(:schooling, student: schooling.student) }.to change(described_class, :count).by(1)
          end
        end

        context "without an end date" do
          it "rejects the new one" do
            expect { create(:schooling, student: schooling.student) }.to raise_error(ActiveRecord::RecordInvalid)
          end

          it "doesn't reject a closed schooling" do
            expect { create(:schooling, :closed, student: schooling.student) }.to(change(described_class, :count).by(1))
          end
        end
      end
    end
  end

  describe "attributive_decision_version" do
    let(:schooling) { create(:schooling) }

    it "defaults to 0" do
      expect(schooling.attributive_decision_version).to eq 0
    end

    context "when an attributive decision is generated" do
      before do
        create(:user, :director, establishment: schooling.establishment)
      end

      it "bumps the version" do
        expect do
          AttributeDecisionGenerator.new(schooling).generate!(StringIO.new)
        end.to change(schooling, :attributive_decision_version).from(0).to(1)
      end
    end
  end

  describe ".current" do
    subject { described_class.current }

    context "when the schooling is over" do
      let(:schooling) { create(:schooling, :closed) }

      it { is_expected.not_to include schooling }
    end

    context "when the schooling is active" do
      let(:schooling) { create(:schooling) }

      it { is_expected.to include schooling }
    end
  end
end
