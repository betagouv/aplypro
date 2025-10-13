# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::AcademicInvitationsController do
  let(:user) { create(:academic_user) }
  let(:other_user) { create(:academic_user) }

  before do
    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return(["01"]) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return("01") # rubocop:disable RSpec/AnyInstance
  end

  describe "DELETE destroy" do
    context "when invitation belongs to current user" do
      let!(:invitation) { create(:academic_invitation, user: user) }

      it "deletes the invitation and redirects with success notice" do
        expect do
          delete academic_academic_invitation_path(invitation)
        end.to change(AcademicInvitation, :count).by(-1)

        expect(response).to redirect_to(academic_invitations_academic_tools_path)
        expect(flash[:notice]).to eq("L'invitation a été supprimée avec succès.")
      end
    end

    context "when invitation belongs to another user" do
      let!(:invitation) { create(:academic_invitation, user: other_user) }

      it "does not delete the invitation and redirects with alert" do
        expect do
          delete academic_academic_invitation_path(invitation)
        end.not_to change(AcademicInvitation, :count)

        expect(response).to redirect_to(academic_invitations_academic_tools_path)
        expect(flash[:alert]).to eq("Vous n'êtes pas autorisé à supprimer cette invitation.")
      end
    end
  end
end
