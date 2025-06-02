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

    context "when the string is nil" do
      let(:str) { nil }

      it { is_expected.to eq :technical_support }
    end

    context "when the string doesn't match anything" do
      let(:str) { "random" }

      it { is_expected.to eq :technical_support }
    end

    I18n.t("asp.errors.rejected.returns").each_key do |key|
      context "when '#{key}' has a return and a response in 'fr.yml'" do
        let(:str) { I18n.t("asp.errors.rejected.returns.#{key}") }

        it { is_expected.to eq key }
      end
    end

    context "when the string match (With REGEX)" do
      let(:str) do
        "Les codes saisis 123456 n existent pas dans le referentiel refdombancaire ou ne sont pas actifs à cette date"
      end

      it { is_expected.to eq :refdombancaire_not_found }
    end
  end
end
