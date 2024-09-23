# frozen_string_literal: true

require "rails_helper"

RSpec.describe RibsController do
  let(:school_year) { SchoolYear.current }
  let(:student) { create(:schooling).student }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: student.classe.establishment) }

  before { sign_in(user) }

  describe "CREATE /rib" do
    it "returns found" do
      post student_ribs_path(student.id),
           params: { rib: attributes_for(:rib, student_id: student.id,
                                               establishment_id: student.classe.establishment.id) }

      expect(response).to have_http_status(:found)
    end

    it "returns 422" do
      post student_ribs_path(student.id), params: { rib: build(:rib, iban: nil).attributes }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /rib" do
    context "when trying to delete a RIB from a student in another establishment" do
      let(:other_student) { create(:schooling).student }
      let(:other_rib) { create(:rib, student: other_student) }

      it "doesnt delete the rib" do
        delete student_rib_path(other_student, other_rib)

        expect(Rib.find(other_rib.id)).not_to be_nil
      end
    end
  end

  describe "POST classes/:classe_id/ribs/bulk_create" do
    let(:rib) { build(:rib, student: student, establishment: student.establishment) }
    let(:rib_params) do
      { name: rib.student.index_name, iban: rib.iban, bic: rib.bic, student_id: rib.student.id }
    end

    context "with a correct request" do
      it "returns 302 (redirected to /classes/:classe_id)" do
        post bulk_create_school_year_class_ribs_path(school_year, student.classe.id),
             params: { ribs: { student.id => rib_params } }

        expect(response).to have_http_status(:found)
      end

      context "when some ribs are invalid" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:students) { create_list(:student, 3, classe: student.classe) }

        let(:rib_params) do
          {
            "ribs" => students.to_h do |student|
              [student.id, build(:rib, student: student).attributes]
            end
          }
        end

        before do
          rib_params["ribs"][students.second.id]["iban"] = ""
        end

        it "tries to save as many ribs as possible" do
          expect do
            post bulk_create_school_year_class_ribs_path(school_year,
                                                         student.classe.id,
                                                         params: rib_params)
          end.to change(Rib, :count).by(2)
        end
      end
    end

    context "when trying to create a RIB for a student in another establishment" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:other_student) { create(:schooling).student }
      let(:rib) { build(:rib, student: other_student, establishment: other_student.establishment) }

      it "returns 403" do
        post bulk_create_school_year_class_ribs_path(school_year, student.classe.id),
             params: { ribs: { other_student.id => rib_params } }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
