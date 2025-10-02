# frozen_string_literal: true

module Academic
  class ToolsController < Academic::ApplicationController
    def index; end

    def remove_keycloak_user
      email = params[:email]
      stream_id = "keycloak_removal_status"

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("keycloak-removal-status",
                                                   partial: "keycloak_removal_loading",
                                                   locals: { email: email })
        end
      end

      Keycloak::RemoveUserJob.perform_later(email, stream_id)
    end

    def invite_keycloak_user
      email = params[:email]
      academy_codes = params[:academy_codes]
      stream_id = "keycloak_invitation_status"

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("keycloak-invitation-status",
                                                   partial: "keycloak_invitation_loading",
                                                   locals: { email: email })
        end
      end

      Keycloak::InviteAcademicUserJob.perform_later(email, academy_codes, stream_id)
    end
  end
end
