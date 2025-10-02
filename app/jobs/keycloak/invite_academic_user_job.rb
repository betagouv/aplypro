# frozen_string_literal: true

module Keycloak
  class InviteAcademicUserJob < ApplicationJob
    def perform(email, academy_codes, stream_id)
      result = invite_user_to_keycloak(email, academy_codes)
      broadcast_result(stream_id, result, email, academy_codes)
    rescue StandardError => e
      broadcast_error(stream_id, e.message)
    end

    private

    def invite_user_to_keycloak(email, academy_codes)
      realm_name = ENV.fetch("KEYCLOAK_MAIN_REALM")
      client = Keycloak::Client.new
      client.add_aplypro_academie_resp_attributes(realm_name, email, academy_codes)
    end

    def broadcast_result(stream_id, result, email, academy_codes)
      broadcast_partial("keycloak_invitation_result", stream_id, result: result, email: email,
                                                                 academy_codes: academy_codes)
    end

    def broadcast_error(stream_id, error_message)
      broadcast_partial("keycloak_invitation_error", stream_id, error: error_message)
    end

    def broadcast_partial(partial_name, stream_id, locals)
      Turbo::StreamsChannel.broadcast_render_to(
        stream_id,
        partial: "academic/tools/#{partial_name}",
        locals: locals
      )
    end
  end
end
