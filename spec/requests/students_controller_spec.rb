# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudentsController do
  let(:school_year) { SchoolYear.current }
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: student.classe.establishment) }

  before { sign_in(user) }

  describe "GET /student" do
    before do
      get school_year_class_student_path(school_year.start_year, class_id: student.classe.id, id: student.id)
    end

    it { is_expected.to render_template(:show) }

    context "when trying to access a student from another establishment" do
      before do
        schooling = create(:schooling)
        get school_year_class_student_path(school_year.start_year,
                                           class_id: schooling.classe.id,
                                           id: schooling.student.id)
      end

      it { is_expected.to redirect_to school_year_classes_path(SchoolYear.current.start_year) }
    end

    context "when trying to access a student that has left the establishment" do
      before do
        student.close_current_schooling!(Date.parse("#{SchoolYear.current.start_year}-10-10"))

        get school_year_class_student_path(school_year.start_year,
                                           class_id: schooling.classe.id,
                                           id: schooling.student.id)
      end

      it { is_expected.to render_template(:show) }
    end
  end
end
