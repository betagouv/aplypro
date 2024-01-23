# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController do
  let(:user) { create(:user, :director) }

  before { sign_in(user) }

  describe "#update" do
    context "when the user is not part of the target establishment" do
      let(:other_establishment) { create(:establishment) }

      it "refuses to update" do
        patch user_path(user), params: { user: { selected_establishment_id: other_establishment.id } }

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
