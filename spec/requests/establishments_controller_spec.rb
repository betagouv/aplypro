# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EstablishmentsController" do
  subject(:create_attributive_decisions) do
    post establishment_create_attributive_decisions_path(establishment), params: { confirmed_director: "1" }
  end

  let(:classe) { create(:classe) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:user, :director, establishment: establishment) }

  before do
    sign_in(user)
  end

  context "when the user does not have a selected establishment" do
    before { user.update!(establishment: nil) }

    it "redirects them towards the select page" do
      get "/home"

      expect(response).to redirect_to select_establishments_path
    end
  end

  describe "POST download_attributive_decisions" do
    let(:schoolings) { create_list(:schooling, 3, :with_attributive_decision, establishment: establishment) }

    it "returns 200" do
      post establishment_download_attributive_decisions_path(establishment)

      expect(response).to have_http_status(:ok)
    end

    context "when an attributive decision is missing" do
      before { schoolings.last.attributive_decision.purge }

      it "still returns 200" do
        post establishment_download_attributive_decisions_path(establishment)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST create_attributive_decisions" do
    before { create_list(:schooling, 10, establishment: establishment) }

    context "when the user is a director" do
      it "returns 200" do
        create_attributive_decisions

        expect(response).to have_http_status(:found)
      end

      it "queues the document creation job" do
        expect { create_attributive_decisions }.to have_enqueued_job(GenerateMissingAttributiveDecisionsJob)
      end
    end

    context "when the user is authorised" do
      before do
        user = create(:user, :authorised, establishment: establishment)

        sign_in(user)
      end

      it "returns forbidden" do
        create_attributive_decisions

        expect(response).to have_http_status(:forbidden)
      end

      it "does not create any documents" do
        expect { create_attributive_decisions }.not_to have_enqueued_job(GenerateMissingAttributiveDecisionsJob)
      end
    end
  end
end
