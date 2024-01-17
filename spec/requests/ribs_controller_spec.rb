# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RibsController" do
  let(:student) { create(:schooling).student }
  let(:user) { create(:user, :director, establishment: student.classe.establishment) }

  before do
    sign_in(user)
    user.update!(establishment: user.establishments.first)
  end

  describe "DESTROY /rib" do
    context "when trying to update a RIB from a student in another establishment" do
      let(:other_student) { create(:schooling).student }
      let(:other_rib) { create(:rib, student: other_student) }

      it "returns 403 (Forbidden)" do
        delete class_student_rib_path(other_student.classe.id, other_student, other_rib)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
