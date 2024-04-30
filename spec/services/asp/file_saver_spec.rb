# frozen_string_literal: true

require "rails_helper"

describe ASP::FileSaver do
  subject(:file_saver) { described_class.new(file) }

  let(:file) { File.new(File.join(Dir.mktmpdir, basename), "w+") }

  %i[integrations rejects].each do |type|
    context "when the file is a #{type} file" do
      let(:request) { create(:asp_request, :sent, filename: "test.xml") }
      let(:basename) { build(:asp_filename, type, identifier: "test") }

      it "attaches to the right request" do
        expect { file_saver.persist_file! }
          .to change { request.reload.attachment_for(type).attached? }.from(false).to(true)
      end

      it "attaches with the right name" do
        expect { file_saver.persist_file! }
          .to change { request.reload.attachment_for(type).filename.to_s }.to(basename)
      end

      context "when the request cannot be found" do
        before { request.file.update!(filename: "bar.xml") }

        it "raises an UnmatchedResponseFile error" do
          expect { file_saver.persist_file! }.to raise_error(ASP::Errors::UnmatchedResponseFile)
        end
      end
    end
  end

  context "when the file is a payment returns file" do
    let(:basename) { build(:asp_filename, :payments) }

    it "creates a new ASP::PaymentReturn" do
      expect { file_saver.persist_file! }.to change(ASP::PaymentReturn, :count).by(1)
    end

    it "stores the filename on the record too" do
      file_saver.persist_file!

      expect(ASP::PaymentReturn.last.filename).to eq basename
    end
  end
end
