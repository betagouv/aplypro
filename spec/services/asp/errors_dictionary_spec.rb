# frozen_string_literal: true

require "rails_helper"

describe ASP::ErrorsDictionary do
  describe ".unpaid_definition" do
    subject { described_class.unpaid_definition(code) }

    context "when the code is nil" do
      let(:code) { nil }

      it { is_expected.to eq :technical_support }
    end

    context "when the code doesn't match anything" do
      let(:code) { "random" }

      it { is_expected.to eq :technical_support }
    end

    ASP::ErrorsDictionary::UNPAID_DEFINITIONS.each do |key, sym|
      context "when the code is #{key}" do
        let(:code) { key }

        it { is_expected.to eq sym }
      end
    end
  end

  describe ".rejected_definition" do
    subject { described_class.rejected_definition(str) }

    context "when the string doesn't match anything" do
      let(:str) { "random" }

      it { is_expected.to be_nil }
    end

    [
      [
        "Les codes saisis (16598, 00001 et FPRLFR21) n existent pas dans le
          referentiel refdombancaire ou ne sont pas actifs à cette date",
        :bank_coordinates_not_found
      ],
      [
        "La demande a été rejetée : Le numÃ©ro administratif MASA2023301 n'est pas unique",
        :technical_support
      ],
      [
        "Le code saisi (VREFHEXAPOSTE) n'existe pas dans le dictionnaire des referentiels",
        :inconsistent_address
      ]
    ].each do |msg, key|
      context "with a message like \"#{msg.truncate(40).strip}\"" do
        let(:str) { msg }

        it { is_expected.to include({ key: key }) }
      end
    end
  end
end
