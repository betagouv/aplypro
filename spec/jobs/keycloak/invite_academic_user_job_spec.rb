# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keycloak::InviteAcademicUserJob do
  describe "#perform" do
    let(:email) { "user@example.com" }
    let(:academy_codes) { %w[06 01] }
    let(:user) { create(:user) }
    let(:stream_id) { "test_stream" }
    let(:success_result) { { success: true, message: "Invitation created successfully" } }

    before do
      allow(Turbo::StreamsChannel).to receive(:broadcast_render_to)
    end

    # rubocop:disable RSpec/ExampleLength
    it "creates invitation record and broadcasts result" do
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

    it "broadcasts error when exception occurs" do
      allow(AcademicInvitation).to receive(:create!).and_raise(StandardError.new("Database error"))

      expect do
        described_class.new.perform(email, academy_codes, user.id, stream_id)
      end.not_to change(AcademicInvitation, :count)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_render_to).with(
        stream_id,
        partial: "academic/tools/keycloak_invitation_error",
        locals: { error: "Database error" }
      )
    end
  end
end
