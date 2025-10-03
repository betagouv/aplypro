# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keycloak::InviteAcademicUserJob do
  describe "#perform" do
    let(:email) { "user@example.com" }
    let(:academy_codes) { %w[06 01] }
    let(:stream_id) { "test_stream" }
    let(:client) { instance_double(Keycloak::Client) }

    before do
      allow(ENV).to receive(:fetch).with("KEYCLOAK_ACADEMIC_REALM").and_return("test-academic-realm")
      allow(Keycloak::Client).to receive(:new).and_return(client)
      allow(Turbo::StreamsChannel).to receive(:broadcast_render_to)
    end

    it "invites user and broadcasts result" do
      allow(client).to receive(:add_aplypro_academie_resp_attributes)
        .with("test-academic-realm", email, academy_codes)
        .and_return({ success: true, message: "User updated successfully" })

      described_class.new.perform(email, academy_codes, stream_id)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_invitation_result",
        locals: {
          result: { success: true, message: "User updated successfully" },
          email: email,
          academy_codes: academy_codes
        }
      )
    end

    it "broadcasts error when exception occurs" do
      allow(client).to receive(:add_aplypro_academie_resp_attributes).and_raise(StandardError.new("Connection failed"))

      described_class.new.perform(email, academy_codes, stream_id)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_invitation_error",
        locals: { error: "Connection failed" }
      )
    end
  end
end
