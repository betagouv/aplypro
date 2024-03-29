# frozen_string_literal: true

require "rails_helper"

RSpec.describe PollPaymentsServerJob do
  include ActiveJob::TestHelper

  let(:server_double) { class_double(ASP::Server) }
  let(:reader_double) { class_double(ASP::FileHandler) }
  let(:double) { instance_double(ASP::FileHandler) }

  before do
    stub_const("ASP::Server", server_double)
    stub_const("ASP::FileHandler", reader_double)

    allow(Dir).to receive(:each_child).and_yield("foobar")

    allow(server_double).to receive(:get_all_files!).and_return("some/folder")
    allow(server_double).to receive(:remove_file!)

    allow(reader_double).to receive(:new).and_return double
    allow(double).to receive(:parse!)
    allow(double).to receive(:file_saved?)
  end

  it "calls the get_all_files! ASP::Server method" do
    perform_enqueued_jobs { described_class.perform_later }

    expect(server_double).to have_received(:get_all_files!)
  end

  it "feeds each file to an ASP::FileHandler" do
    perform_enqueued_jobs { described_class.perform_later }

    expect(double).to have_received(:parse!)
  end

  context "when the reader manages to save the file" do
    before { allow(double).to receive(:file_saved?).and_return true }

    it "deletes it on the server" do
      perform_enqueued_jobs { described_class.perform_later }

      expect(server_double).to have_received(:remove_file!).with(path: "foobar")
    end
  end

  context "when the original request can't be found" do
    before do
      allow(double).to receive(:parse!).and_raise ASP::Errors::UnmatchedResponseFile
    end

    it "does not remove the file off the server" do
      perform_enqueued_jobs { described_class.perform_later }

      expect(server_double).not_to have_received(:remove_file!).with(path: "foobar")
    end
  end

  context "when the request can't be processed" do
    before do
      allow(double).to receive(:parse!).and_raise ASP::Errors::ResponseFileParsingError
    end

    context "when the file has been attached" do
      before { allow(double).to receive(:file_saved?).and_return true }

      it "deletes it on the server" do
        perform_enqueued_jobs { described_class.perform_later }

        expect(server_double).to have_received(:remove_file!).with(path: "foobar")
      end
    end

    context "when the file has not been attached" do
      before { allow(double).to receive(:file_saved?).and_return false }

      it "doesn't delete it on the server" do
        perform_enqueued_jobs { described_class.perform_later }

        expect(server_double).not_to have_received(:remove_file!).with(path: "foobar")
      end
    end
  end
end
