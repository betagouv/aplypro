# frozen_string_literal: true

require "rails_helper"

describe ASP::FileReader do
  subject(:reader) { described_class.new(filepath) }

  let(:basename) { "rejets_integ_idp_foobar.csv" }

  let!(:request) { create(:asp_request, :sent, filename: "foobar.xml") }
  let(:file) { Tempfile.create(basename) }
  let(:filepath) { file.path }

  let(:rejects_reader) { instance_double(ASP::Readers::RejectsFileReader) }

  before do
    stub_const("ASP::Readers::RejectsFileReader", class_double(ASP::Readers::RejectsFileReader, new: rejects_reader))

    allow(rejects_reader).to receive(:process!)
  end

  context "when the file is a rejects file" do
    let(:basename) { "rejets_integ_idp_foobar.csv" }

    it "delegates to the RejectsReader" do
      reader.parse!

      expect(rejects_reader).to have_received(:process!)
    end

    it "attaches the file" do
      reader.parse!

      expect(request.rejects_file).to be_attached
    end
  end

  context "when the file is a payment returns file" do
    let(:basename) { "renvoi_paiement_APLYPROTEST_20240129.xml" }

    it "creates a new ASP::PaymentReturn" do
      expect { reader.parse! }.to change(ASP::PaymentReturn, :count).by(1)
    end

    it "attaches the file to the record" do
      reader.parse!

      expect(ASP::PaymentReturn.last.file).to be_attached
    end

    it "stores the filename on the record too" do
      reader.parse!

      expect(ASP::PaymentReturn.last.filename).to eq basename
    end
  end

  describe "#original_filename" do
    subject { described_class.new(filepath).original_filename }

    context "when the file is a rejects file" do
      let(:filepath) { "/tmp/rejets_integ_idp_foobar_123_xml.csv" }

      it { is_expected.to eq "foobar_123_xml.xml" }
    end

    context "when the file is an integration file" do
      let(:filepath) { "tmp/identifiants_generes_foobar_456_xml.csv" }

      it { is_expected.to eq "foobar_456_xml.xml" }
    end

    context "when the file is a payment file" do
      let(:filepath) { "renvoi_paiement_aplypro_20240129.xml" }

      it { is_expected.to be_nil }
    end
  end

  describe "find_request!" do
    subject(:find_request) { described_class.new(filepath).request }

    before do
      create(:asp_request, filename: "foobar.xml")
    end

    let(:filepath) { "tmp/identifiants_generes_foobar.csv" }

    it { is_expected.to be_an ASP::Request }

    context "when there is no such request" do
      let(:filepath) { "tmp/identifiants_generes_123.csv" }

      it "raises a specific error" do
        expect { find_request }.to raise_error ASP::Errors::UnmatchedResponseFile
      end
    end
  end
end
