# frozen_string_literal: true

module Keycloak
  class RemoveUserJob < ApplicationJob
    def perform(email, stream_id)
      result = remove_user_from_keycloak(email)
      broadcast_result(stream_id, result, email)
    rescue StandardError => e
      broadcast_error(stream_id, e.message)
    end

    private

    def remove_user_from_keycloak(email)
      realm_name = ENV.fetch("KEYCLOAK_MAIN_REALM")
      client = Keycloak::Client.new
      client.remove_user_by_email(realm_name, email)
    end

    def broadcast_result(stream_id, result, email)
      broadcast_partial("keycloak_removal_result", stream_id, result: result, email: email)
    end

    def broadcast_error(stream_id, error_message)
      broadcast_partial("keycloak_removal_error", stream_id, error: error_message)
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
