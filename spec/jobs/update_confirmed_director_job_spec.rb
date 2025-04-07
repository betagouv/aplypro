# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateConfirmedDirectorJob do
  describe "#perform" do
    let(:establishment) { create(:establishment, uai: "0123456X") }
    let!(:director) { create(:user, :confirmed_director, establishment: establishment) }
    let(:rua_client) { instance_double(Rua::Client) }
    let(:rua_response) do
      [{
        "mails" => [
          { "libelle" => director.email }
        ]
      }]
    end

    before do
      allow(Rua::Client).to receive(:new).and_return(rua_client)
      allow(rua_client).to receive(:dirs_for_uai).with(establishment.uai).and_return(rua_response)
    end

    it "updates the confirmed director for the establishment" do
      described_class.perform_now(establishment.uai)

      expect(establishment.reload.confirmed_director).to eq(director)
    end

    context "when no director is found in RUA" do
      let(:rua_response) { [] }

      it "raises NoListedDirector error" do
        expect do
          described_class.perform_now(establishment.uai)
        end.to raise_error(UpdateConfirmedDirectorJob::NoListedDirector)
      end
    end

    context "when multiple directors are found in RUA" do
      let(:rua_response) do
        [
          { "mails" => [{ "libelle" => "director1@example.com" }] },
          { "mails" => [{ "libelle" => "director2@example.com" }] }
        ]
      end

      it "raises MultipleDirector error" do
        expect do
          described_class.perform_now(establishment.uai)
        end.to raise_error(UpdateConfirmedDirectorJob::MultipleDirector)
      end
    end

    context "when establishment is not found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.perform_now("invalid_uai")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when director user is not found" do
      let(:rua_response) do
        [{
          "mails" => [
            { "libelle" => "nonexistent@example.com" }
          ]
        }]
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.perform_now(establishment.uai)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
