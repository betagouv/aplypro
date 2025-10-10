# frozen_string_literal: true

module Keycloak
  class ApplyInvitationAttributesJob < ApplicationJob
    def perform(realm_name, email, academy_codes)
      client = Keycloak::Client.new
      client.add_aplypro_academie_resp_attributes(realm_name, email, academy_codes)
    end
  end
end
