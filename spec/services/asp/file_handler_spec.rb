# frozen_string_literal: true

require "rails_helper"

describe ASP::FileHandler do
  subject(:reader) { described_class.new(file) }

  let(:request_identifier) { "foobar" }
  let!(:request) { create(:asp_request, :sent, filename: "#{request_identifier}.xml") }
  let(:file) { File.new(File.join(Dir.mktmpdir, basename), "w+") }

  # can't reduce much more
  # rubocop:disable Rspec/MultipleMemoizedHelpers
  shared_examples "a reader for the ASP integration process" do |type|
    let(:basename) { build(:asp_filename, type, identifier: request_identifier) }
    let(:reader_class) { "ASP::Readers::#{type.capitalize}FileReader".classify }
    let(:file_reader) { instance_double(reader_class) }

    before do
      stub_const(reader_class, class_double(reader_class, new: file_reader))

      allow(file_reader).to receive(:process!)
    end

    it "delegates to the appropriate reader" do
      reader.parse!

      expect(file_reader).to have_received(:process!)
    end

    it "attaches the file" do
      reader.parse!

      expect(request.send("#{type}_file")).to be_attached
    end

    it "can tell the file was attached correctly" do
      expect { reader.parse! }.to change(reader, :file_saved?).from(false).to(true)
    end
  end
  # rubocop:enable Rspec/MultipleMemoizedHelpers

  %i[integrations rejects].each do |type|
    context "when the file is #{type} file" do
      it_behaves_like "a reader for the ASP integration process", type
    end
  end

  context "when the file is a payment returns file" do
    let(:basename) { build(:asp_filename, :payments) }

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

    it "knows whether the file was saved" do
      expect { reader.parse! }.to change(reader, :file_saved?).from(false).to(true)
    end
  end
end
