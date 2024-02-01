# frozen_string_literal: true

require "rails_helper"

require "attribute_decision_generator"

RSpec.describe Schooling do
  subject(:schooling) { create(:schooling) }

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

  describe "attributive_decision_number" do
    subject(:number) { schooling.attributive_decision_number }

    context "when the MEF is from the MENJ" do
      context "when the establishment is private" do
        before { allow(schooling.mef).to receive(:bop).and_return :menj_private }

        it { is_expected.to start_with "ENPR" }
      end

      context "when the establishment is public" do
        before { allow(schooling.mef).to receive(:bop).and_return :menj_public }

        it { is_expected.to start_with "ENPU" }
      end
    end

    context "when the MEF is from the MASA" do
      before { allow(schooling.mef).to receive(:bop).and_return :masa }

      it { is_expected.to start_with "MASA" }
    end
  end

  describe "attributive_decision_version" do
    let(:schooling) { create(:schooling) }

    it "defaults to 0" do
      expect(schooling.attributive_decision_version).to eq 0
    end

    context "when an attributive decision is generated" do
      before do
        create(:user, :confirmed_director, establishment: schooling.establishment)
      end

      it "bumps the version" do
        expect do
          AttributeDecisionGenerator.new(schooling).generate!(StringIO.new)
        end.to change(schooling, :attributive_decision_version).from(0).to(1)
      end
    end
  end

  describe "attributive_decision_key" do
    let(:schooling) { create(:schooling) }
    let(:uai) { schooling.establishment.uai }

    before do
      schooling.classe.update!(label: "1ERE APEX TEST")
      schooling.student.update!(first_name: "Jeanne", last_name: "DUPONT", asp_file_reference: "ref123")
    end

    it "creates a sane filename" do
      key =
        "#{uai}/2023/1ere-apex-test/DUPONT_Jeanne_décision-d-attribution_#{schooling.attributive_decision_number}.pdf"

      expect(schooling.attributive_decision_key).to eq key
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

  describe ".former" do
    subject { described_class.former }

    context "when the schooling is over" do
      let(:schooling) { create(:schooling, :closed) }

      it { is_expected.to include schooling }
    end

    context "when the schooling is active" do
      let(:schooling) { create(:schooling) }

      it { is_expected.not_to include schooling }
    end
  end

  describe "#reopen!" do
    let(:schooling) { create(:schooling, :closed) }

    it "resets the end date" do
      expect { schooling.reopen! }.to change(schooling, :open?).from(false).to(true)
    end
  end

  describe "with_attributive_decisions" do
    subject { described_class.with_attributive_decisions }

    let(:schooling) { create(:schooling) }

    context "when the schooling does not have an attached attributive decision" do
      it { is_expected.not_to include(schooling) }
    end

    context "when the schooling has an attached attributive decision" do
      let(:schooling) { create(:schooling, :with_attributive_decision) }

      it { is_expected.to include(schooling) }
    end
  end
end
