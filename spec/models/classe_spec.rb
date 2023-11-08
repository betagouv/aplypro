# frozen_string_literal: true

require "rails_helper"

RSpec.describe Classe do
  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:mef).class_name("Mef") }
    it { is_expected.to have_many(:students).order("last_name") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:start_year) }
    it { is_expected.to validate_numericality_of(:start_year).only_integer.is_greater_than_or_equal_to(2023) }
  end

  describe ".current" do
    subject { described_class.current }

    let(:last_year) { create(:classe, start_year: 2020) }
    let(:next_year) { create(:classe, start_year: 2024) }
    let(:current) { create(:classe, start_year: 2023) }

    before do
      allow(ENV)
        .to receive(:fetch)
        .with("APLYPRO_SCHOOL_YEAR")
        .and_return("2023")
    end

    it { is_expected.to contain_exactly(current) }
  end

  describe "create_bulk_pfmp" do
    subject(:classe) { create(:classe, :with_students, students_count: 5) }

    let(:params) { { start_date: Date.yesterday, end_date: Date.tomorrow } }

    it "creates a PFMP for each student" do
      expect { classe.create_bulk_pfmp(params) }.to change(Pfmp, :count).from(0).to(5)
    end

    context "when there are past/gone students" do
      it "does not include them" do
        student = classe.students.last

        student.close_current_schooling!

        expect { classe.create_bulk_pfmp(params) }.not_to change(student, :pfmps)
      end
    end
  end

  describe ".with_attributive_decisions" do
    let(:classe_with_no_ad) { create(:classe, :with_students) }
    let(:classe_with_ad) { create(:classe, :with_students) }

    before do
      create(:schooling, :with_attributive_decision, classe: classe_with_ad)
      create(:schooling, classe: classe_with_no_ad)
    end

    it "returns the classes which have attributive decisions" do
      expect(described_class.with_attributive_decisions).to contain_exactly(classe_with_ad)
    end
  end
end
