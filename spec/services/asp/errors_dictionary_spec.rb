# frozen_string_literal: true

require "rails_helper"

describe ASP::ErrorsDictionary do
  describe ".definition" do
    subject { described_class.rejected_definition(str) }

    context "when the string doesn't match anything" do
      let(:str) { "random" }

      it { is_expected.to be_nil }
    end

    [
      [
        "
Les codes saisis (16598, 00001 et FPRLFR21) n existent pas dans le
referentiel refdombancaire ou ne sont pas actifs à cette date",
        :bank_coordinates_not_found
      ],
      [
        "La demande a été rejetée : Le numÃ©ro administratif MASA2023301 n'est pas unique",
        :administrative_number_already_taken
      ]
    ].each do |msg, key|
      context "with a message like \"#{msg.truncate(40).strip}\"" do
        let(:str) { msg }

        it { is_expected.to include({ key: key }) }
      end
    end
  end
end
