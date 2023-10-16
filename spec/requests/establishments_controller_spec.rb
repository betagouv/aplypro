# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EstablishmentsController" do
  let(:classe) { create(:classe) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:user, :director, establishment: establishment) }

  before do
    sign_in(user)
  end

  describe "POST create_attributive_decisions" do
    context "when the user is a director" do
      it "returns 200" do
        post establishment_create_attributive_decisions_path(establishment)

        expect(response).to have_http_status(:found)
      end

      it "create some documents" do
        expect(establishment.attributive_decisions.size).to eq classe.students.size
      end
    end

    context "when the user is authorised" do
      before do
        user = create(:user, :authorised, establishment: establishment)

        sign_in(user)
      end

      it "returns forbidden" do
        post establishment_create_attributive_decisions_path(establishment)

        expect(response).to have_http_status(:forbidden)
      end

      it "does not create any documents" do
        expect(establishment.attributive_decisions).to be_empty
      end
    end
  end
end
