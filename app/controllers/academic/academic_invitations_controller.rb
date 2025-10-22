# frozen_string_literal: true

module Academic
  class AcademicInvitationsController < Academic::ApplicationController
    def destroy
      @invitation = current_user.invitations.find(params[:id])
      @invitation.destroy
      redirect_to academic_invitations_academic_tools_path,
                  notice: t(".success")
    rescue ActiveRecord::RecordNotFound
      redirect_to academic_invitations_academic_tools_path,
                  alert: t(".unauthorized")
    end
  end
end
