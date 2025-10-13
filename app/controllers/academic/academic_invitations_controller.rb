# frozen_string_literal: true

module Academic
  class AcademicInvitationsController < Academic::ApplicationController
    def destroy
      @invitation = AcademicInvitation.find(params[:id])

      if @invitation.user_id == current_user.id
        @invitation.destroy
        redirect_to academic_invitations_academic_tools_path, notice: "L'invitation a été supprimée avec succès."
      else
        redirect_to academic_invitations_academic_tools_path, alert: "Vous n'êtes pas autorisé à supprimer cette invitation."
      end
    end
  end
end
