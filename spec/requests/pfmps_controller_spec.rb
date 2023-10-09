# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PfmpsController" do
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }
  let(:user) { create(:user, establishment: student.classe.establishment) }
  let(:pfmp) { create(:pfmp, student: student) }

  before do
    sign_in(user)
  end

  describe "GET /pfmp" do
    before do
      get class_student_pfmp_path(class_id: student.classe.id, student_id: student.id, id: pfmp.id)
    end

    it { is_expected.to render_template(:show) }

    context "when trying to access a PFMP from another establishment" do
      before do
        schooling = create(:schooling)
        get class_student_pfmp_path(class_id: schooling.classe.id, student_id: schooling.student.id, id: pfmp.id)
      end

      it { is_expected.to redirect_to classes_path }
    end
  end
end
