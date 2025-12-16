# frozen_string_literal: true

require "rails_helper"

require "./spec/support/shared/student_mapper"

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Student::Mappers::Base do
  let(:uai) { create(:establishment).uai }
  let(:mapper) { described_class.new({}, uai) }

  describe "#handle_current_schooling_end_date" do
    subject(:method) { mapper.handle_current_schooling_end_date(schooling) }

    let(:classe) { create(:classe) }
    let(:student) { create(:student) }
    let(:current_schooling) { create(:schooling, student:, classe:) }

    context "when the schooling is closed" do
      let(:schooling) do
        Schooling.find_or_initialize_by(classe:,
                                        student:,
                                        start_date: Date.parse("#{SchoolYear.current.start_year}-09-15"),
                                        end_date: Date.parse("#{SchoolYear.current.start_year}-10-01"))
      end

      it { expect { method }.not_to(change { current_schooling.reload.end_date }) }
    end

    context "when the schooling is the current schooling" do
      let(:schooling) { current_schooling }

      it { expect { method }.not_to(change { current_schooling.reload.end_date }) }
    end

    context "when the schooling is open, later, and both are in current school year" do
      let(:schooling) do
        Schooling.find_or_initialize_by(classe:,
                                        student:,
                                        start_date: Date.parse("#{SchoolYear.current.start_year}-09-15"))
      end

      it "sets the current schooling end date to the new schooling start date - 1 day" do
        expect { method }.to change { current_schooling.reload.end_date }.from(nil).to(schooling.start_date - 1.day)
      end
    end

    context "when the schooling is open, later, and both are in the same school year but not in current school year" do
      let(:another_school_year) { create(:school_year, start_year: 2020) }
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:current_schooling) { create(:schooling, student:, classe: another_classe) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe: another_classe,
                                        student:,
                                        start_date: Date.parse("#{another_school_year.start_year}-09-15"))
      end

      it "sets the current schooling end date to the new schooling start date - 1 day" do
        expect { method }.to change { current_schooling.reload.end_date }.from(nil).to(schooling.start_date - 1.day)
      end
    end

    context "when the schooling is open, later, but not in the same school year" do
      let(:another_school_year) { create(:school_year, start_year: SchoolYear.current.start_year + 5) }
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe: another_classe,
                                        student:,
                                        start_date: Date.parse("#{another_school_year.start_year}-09-15"))
      end

      it "sets the current schooling end date to the end of the school year range" do
        expect { method }
          .to change { current_schooling.reload.end_date }
          .from(nil).to(Date.parse("#{current_schooling.school_year.end_year}-09-01"))
      end
    end

    context "when the schooling is open, earlier, both are in current school year" do
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe:, student:, start_date: current_schooling.start_date - 1.day)
      end

      it { expect { method }.to change { current_schooling.reload.end_date }.from(nil).to(Time.zone.today) }
    end

    context "when the schooling is open, earlier, and only the current schooling is in the current school year" do
      let(:another_school_year) { create(:school_year, start_year: 2020) }
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe: another_classe,
                                        student:,
                                        start_date: Date.parse("#{another_school_year.start_year}-09-15"))
      end

      it { expect { method }.to change { current_schooling.reload.end_date }.from(nil).to(Time.zone.today) }
    end

    context "when the schooling is open, earlier, and both are in same school year but not in the current one" do
      let(:another_school_year) { create(:school_year, start_year: 2020) }
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:current_schooling) { create(:schooling, student:, classe: another_classe) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe: another_classe,
                                        student:,
                                        start_date: current_schooling.start_date - 1.day)
      end

      it "sets the current schooling end date to the end of the school year range" do
        expect { method }
          .to change { current_schooling.reload.end_date }
          .from(nil).to(Date.parse("#{current_schooling.school_year.end_year}-09-01"))
      end
    end

    context "when the schooling is open, earlier, and both are not in same school year and not in the current one" do
      let(:another_school_year) { create(:school_year, start_year: 2020) }
      let(:another_earlier_school_year) { create(:school_year, start_year: 2019) }
      let(:another_classe) { create(:classe, school_year: another_school_year) }
      let(:another_earlier_classe) { create(:classe, school_year: another_earlier_school_year) }
      let(:current_schooling) { create(:schooling, student:, classe: another_classe) }
      let(:schooling) do
        Schooling.find_or_initialize_by(classe: another_earlier_classe,
                                        student:,
                                        start_date: Date.parse("#{another_earlier_school_year.start_year}-09-15"))
      end

      it "sets the current schooling end date to the end of the school year range" do
        expect { method }
          .to change { current_schooling.reload.end_date }
          .from(nil).to(Date.parse("#{current_schooling.school_year.end_year}-09-01"))
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
