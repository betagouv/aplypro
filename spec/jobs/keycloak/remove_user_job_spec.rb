# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keycloak::RemoveUserJob do
  describe "#perform" do
    let(:email) { "user@example.com" }
    let(:stream_id) { "test_stream" }
    let(:client) { instance_double(Keycloak::Client) }

    before do
      allow(ENV).to receive(:fetch).with("KEYCLOAK_MAIN_REALM").and_return("test-realm")
      allow(Keycloak::Client).to receive(:new).and_return(client)
      allow(Turbo::StreamsChannel).to receive(:broadcast_render_to)
    end

    it "removes user and broadcasts result" do
      allow(client).to receive(:remove_user_by_email).with("test-realm", email).and_return(
        { success: true, message: "User removed successfully" }
      )

      described_class.new.perform(email, stream_id)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_removal_result",
        locals: { result: { success: true, message: "User removed successfully" }, email: email }
      )
    end

    it "broadcasts error when exception occurs" do
      allow(client).to receive(:remove_user_by_email).and_raise(StandardError.new("Connection failed"))

      described_class.new.perform(email, stream_id)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_removal_error",
        locals: { error: "Connection failed" }
      )
    end
  end
end
