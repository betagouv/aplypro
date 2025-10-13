# frozen_string_literal: true

module Academic
  class AcademicInvitationsController < Academic::ApplicationController
    def destroy
      @invitation = AcademicInvitation.find(params[:id])

      if @invitation.user_id == current_user.id
        @invitation.destroy
        redirect_to academic_invitations_academic_tools_path,
                    notice: t(".success")
      else
        redirect_to academic_invitations_academic_tools_path,
                    alert: t(".unauthorized")
      end
    end
  end
end
