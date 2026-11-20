# frozen_string_literal: true

require "rails_helper"

# rubocop:disable-next RSpec/MultipleMemoizedHelpers
RSpec.describe EstablishmentsController do
  subject(:create_attributive_decisions) do
    post school_year_establishment_create_attributive_decisions_path(school_year, establishment),
         params: { confirmed_director: "1" }
  end

  let(:reissue_attributive_decisions) do
    post school_year_establishment_reissue_attributive_decisions_path(school_year, establishment),
         params: { confirmed_director: "1" }
  end

  let(:school_year) { SchoolYear.current }
  let(:classe) { create(:classe, school_year: school_year) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:user, :director, :with_selected_establishment, establishment: establishment) }

  before { sign_in(user) }

  context "when the user does not have a selected establishment" do
    before { user.update!(selected_establishment: nil) }

    it "redirects them towards the select page" do
      get "/"

      expect(response).to redirect_to user_select_establishment_path(user)
    end
  end

  describe "POST download_attributive_decisions" do
    let(:schoolings) { create_list(:schooling, 3, :with_attributive_decision, establishment: establishment) }

    it "returns 200" do
      post school_year_establishment_download_attributive_decisions_path(school_year, establishment)

      expect(response).to have_http_status(:ok)
    end

    it "keeps available PDFs unchanged" do
      schooling = create(:schooling, :with_attributive_decision, classe: classe)

      post school_year_establishment_download_attributive_decisions_path(school_year, establishment)

      expect(schooling.attributive_decision.download).to eq("hello")
    end

    context "when decisions are being generated" do
      before { create(:schooling, classe: classe, generating_attributive_decision: true) }

      it "redirects back with the generation in progress message" do
        post school_year_establishment_download_attributive_decisions_path(school_year, establishment)

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("panels.attributive_decisions.generating.body.other"))
      end
    end

    context "when an attached PDF is missing from storage" do
      let(:schooling) { create(:schooling, :with_attributive_decision, classe: classe) }
      let(:blob) { schooling.attributive_decision.blob }

      before { blob.service.delete(blob.key) }

      it "regenerates the PDF before including it in the ZIP" do
        post school_year_establishment_download_attributive_decisions_path(school_year, establishment)

        archive = StringIO.new(response.body)
        entry = ZipKit::FileReader.read_zip_structure(io: archive).first
        expect(entry.filename.force_encoding(Encoding::UTF_8)).to eq(blob.key)
        expect(entry.extractor_from(archive).extract(1024)).to start_with("%PDF-")
        expect(blob.reload.open(&:read)).to start_with("%PDF-")
      end

      it "preserves the decision number, filename and storage path" do
        original = [schooling.attributive_decision_number, blob.id, blob.key, blob.filename.to_s]

        post school_year_establishment_download_attributive_decisions_path(school_year, establishment)

        decision = schooling.reload.attributive_decision
        expect([schooling.attributive_decision_number, decision.blob.id, decision.key, decision.filename.to_s])
          .to eq(original)
      end
    end

    context "when an attributive decision is missing" do
      before { schoolings.last.attributive_decision.purge }

      it "still returns 200" do
        post school_year_establishment_download_attributive_decisions_path(school_year, establishment)

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
        expect { create_attributive_decisions }.to have_enqueued_job(Generate::AttributiveDecisionsJob)
      end
    end

    context "when the user is authorised" do
      before do
        user = create(:user, :authorised, :with_selected_establishment, establishment: establishment)

        sign_in(user)
      end

      it "returns forbidden" do
        create_attributive_decisions

        expect(response).to have_http_status(:forbidden)
      end

      it "does not create any documents" do
        expect { create_attributive_decisions }.not_to have_enqueued_job(Generate::AttributiveDecisionsJob)
      end
    end
  end

  describe "POST reissue_attributive_decisions" do
    before { create_list(:schooling, 10, establishment: establishment) }

    context "when the user is a director" do
      it "returns 200" do
        reissue_attributive_decisions

        expect(response).to have_http_status(:found)
      end

      it "queues the document creation job" do
        expect { reissue_attributive_decisions }.to have_enqueued_job(Generate::AttributiveDecisionsJob)
      end
    end
  end
end
