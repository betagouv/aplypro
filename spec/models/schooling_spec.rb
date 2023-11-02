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

  describe "callbacks" do
    describe "after_create" do
      subject(:schooling) { build(:schooling, student: student) }

      let(:student) { create(:student) }

      it "sets itself as the current schooling" do
        expect { schooling.save! }.to change(student, :current_schooling).from(nil).to(schooling)
      end

      context "when there is already a schooling" do
        let!(:previous) { create(:schooling, student: student) }

        it "ends the previous one" do
          expect { schooling.save! }.to change(previous, :end_date).from(nil).to(Time.zone.today)
        end
      end

      it "doesn't set its own end date" do
        expect { schooling.save! }.not_to change(schooling, :end_date)
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
end
