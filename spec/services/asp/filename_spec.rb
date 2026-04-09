# frozen_string_literal: true

require "rails_helper"

describe ASP::Filename do
  subject(:filename) { described_class.new(str) }

  describe "#kind" do
    subject { filename.kind }

    %i[rejects integrations payments].each do |type|
      context "when the filename looks like a #{type} file" do
        let(:str) { build(:asp_filename, type) }

        it { is_expected.to eq type }
      end
    end

    context "when the filename looks like a correction_adresse_integrations file" do
      let(:str) { "identifiants_generes_nps_ficimport_correction_adresse_foobar.csv" }

      it { is_expected.to eq :correction_adresse_integrations }
    end

    context "when the filename looks like a correction_adresse_rejects file" do
      let(:str) { "rejets_integ_idp_nps_ficimport_correction_adresse_foobar.csv" }

      it { is_expected.to eq :correction_adresse_rejects }
    end
  end

  describe "original_filename" do
    subject { filename.original_filename }

    context "when the file is payments file" do
      let(:str) { build(:asp_filename, :payments) }

      it { is_expected.to be_nil }
    end

    %i[rejects integrations].each do |type|
      context "when the file is #{type} file" do
        let(:str) { build(:asp_filename, type, identifier: "some identifier") }

        it { is_expected.to eq "some identifier.xml" }
      end
    end

    context "when the file is correction_adresse_integrations file" do
      let(:str) { "identifiants_generes_nps_ficimport_correction_adresse_some_identifier.csv" }

      it { is_expected.to eq "nps_ficimport_correction_adresse_some_identifier.xml" }
    end

    context "when the file is correction_adresse_rejects file" do
      let(:str) { "rejets_integ_idp_nps_ficimport_correction_adresse_some_identifier.csv" }

      it { is_expected.to eq "nps_ficimport_correction_adresse_some_identifier.xml" }
    end
  end
end
