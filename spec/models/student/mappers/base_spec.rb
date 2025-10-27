# frozen_string_literal: true

require "rails_helper"

require "./spec/support/shared/student_mapper"

describe Student::Mappers::Base do
  let(:uai) { create(:establishment).uai }
  let(:mapper) { described_class.new({}, uai) }

  describe "#manage_end_date" do
    subject(:method) { mapper.manage_end_date(schooling) }

    let(:classe) { create(:classe) }
    let(:student) { create(:student) }
    let(:current_schooling) { create(:schooling, student:, classe:) }

    context "when the schooling is nil" do
      let(:schooling) { nil }

      it { expect { method }.not_to change { current_schooling.reload.end_date } }
    end

    context "when the schooling is closed" do
      let(:schooling) do
        Schooling.find_or_initialize_by(classe:,
                                        student:,
                                        start_date: Date.parse("#{SchoolYear.current.start_year}-09-15"),
                                        end_date: Date.parse("#{SchoolYear.current.start_year}-10-01"))
      end

      it { expect { method }.not_to change { current_schooling.reload.end_date } }
    end

    context "when the schooling is open and in the same school year" do
      let(:schooling) do
        Schooling.find_or_initialize_by(classe:,
                                        student:,
                                        start_date: Date.parse("#{SchoolYear.current.start_year}-09-15"))
      end

      it "sets the current schooling end date to the new schooling start date - 1 day" do
        expect { method }.to change { current_schooling.reload.end_date }.from(nil).to(schooling.start_date - 1.day)
      end
    end

    context "when the schooling is open but not in the same school year" do
      let(:another_school_year) { create(:school_year, start_year: 2030) }
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe: another_classe,
                                        student:,
                                        start_date: Date.parse("#2030-09-15"))
      end

      it "sets the current schooling end date to the end of the school year range" do
        expect { method }
          .to change { current_schooling.reload.end_date }
                .from(nil).to(Date.parse("#{SchoolYear.current.end_year}-08-31"))
      end
    end
  end
end
