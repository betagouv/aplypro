# frozen_string_literal: true

require "rails_helper"

RSpec.describe "StudentsControllers" do
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: student.classe.establishment) }

  before { sign_in(user) }

  describe "GET /student" do
    before do
      get class_student_path(class_id: student.classe.id, id: student.id)
    end

    it { is_expected.to render_template(:show) }

    context "when trying to access a student from another establishment" do
      before do
        schooling = create(:schooling)
        get class_student_path(class_id: schooling.classe.id, id: schooling.student.id)
      end

      it { is_expected.to redirect_to classes_path }
    end

    context "when trying to access a student that has left the establishment" do
      before do
        student.close_current_schooling!

        get class_student_path(class_id: schooling.classe.id, id: schooling.student.id)
      end

      it { is_expected.to render_template(:show) }
    end
  end
end
