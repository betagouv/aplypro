# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keycloak::InviteAcademicUserJob do
  describe "#perform" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:email) { "user@example.com" }
    let(:academy_codes) { %w[06 01] }
    let(:user) { create(:user) }
    let(:stream_id) { "test_stream" }
    let(:client) { instance_double(Keycloak::Client) }
    let(:success_result) { { success: true, message: "User updated successfully" } }

    before do
      allow(ENV).to receive(:fetch).with("KEYCLOAK_ACADEMIC_REALM").and_return("test-academic-realm")
      allow(Keycloak::Client).to receive(:new).and_return(client)
      allow(Turbo::StreamsChannel).to receive(:broadcast_render_to)
    end

    # rubocop:disable RSpec/ExampleLength
    it "invites user, creates invitation record, and broadcasts result" do
      allow(client).to receive(:add_aplypro_academie_resp_attributes)
        .with("test-academic-realm", email, academy_codes)
        .and_return(success_result)

      expect do
        described_class.new.perform(email, academy_codes, user.id, stream_id)
      end.to change(AcademicInvitation, :count).by(1)

      invitation = AcademicInvitation.last
      expect(invitation.email).to eq(email)
      expect(invitation.academy_codes).to eq(academy_codes)
      expect(invitation.user_id).to eq(user.id)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_invitation_result",
        locals: { result: success_result, email: email, academy_codes: academy_codes }
      )
    end
    # rubocop:enable RSpec/ExampleLength

    it "broadcasts error when exception occurs and does not create invitation" do
      allow(client).to receive(:add_aplypro_academie_resp_attributes).and_raise(StandardError.new("Connection failed"))

      expect do
        described_class.new.perform(email, academy_codes, user.id, stream_id)
      end.not_to change(AcademicInvitation, :count)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_invitation_error",
        locals: { error: "Connection failed" }
      )
    end

    it "does not create invitation record when keycloak invitation fails" do
      failure_result = { success: false, error: "User creation failed" }
      allow(client).to receive(:add_aplypro_academie_resp_attributes)
        .with("test-academic-realm", email, academy_codes)
        .and_return(failure_result)

      expect do
        described_class.new.perform(email, academy_codes, user.id, stream_id)
      end.not_to change(AcademicInvitation, :count)
    end
  end
end
