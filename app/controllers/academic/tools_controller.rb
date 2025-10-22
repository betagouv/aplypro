# frozen_string_literal: true

module Academic
  class ToolsController < Academic::ApplicationController
    before_action :require_admin, only: %i[remove_keycloak_user invite_keycloak_user]

    def index; end

    def academic_invitations
      @invitations = AcademicInvitation.where(user: current_user).order(created_at: :desc)
      infer_page_title
    end

    def establishment_invitations
      @invitations = EstablishmentInvitation.where(user: current_user).order(created_at: :desc)
      infer_page_title
    end

    def remove_keycloak_user
      email = params[:email]
      stream_id = "keycloak_removal_status"

      return render_email_error("keycloak-removal-status") unless valid_email?(email)

      render_keycloak_loading("keycloak-removal-status", "keycloak_removal_loading", email: email)
      Keycloak::RemoveUserJob.perform_later(email, stream_id)
    end

    def invite_keycloak_user
      email = params[:email]
      academy_codes = Array(params[:academy_codes]).compact_blank
      stream_id = "keycloak_invitation_status"

      return render_email_error("keycloak-invitation-status") unless valid_email?(email)

      render_keycloak_loading("keycloak-invitation-status", "keycloak_invitation_loading", email: email)
      Keycloak::InviteAcademicUserJob.perform_later(email, academy_codes, current_user.id, stream_id)
    end

    private

    def require_admin
      return if current_user.admin?

      redirect_to academic_tools_path, alert: t(".unauthorized")
    end

    def valid_email?(email)
      email.present? && email.match?(URI::MailTo::EMAIL_REGEXP)
    end

    def render_email_error(target_id)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(target_id,
                                                   partial: "keycloak_error",
                                                   locals: { message: t(".invalid_email") })
        end
      end
    end

    def render_keycloak_loading(target_id, partial_name, locals)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(target_id, partial: partial_name, locals: locals)
        end
      end
    end
  end
end
