# frozen_string_literal: true

require "rails_helper"

RSpec.describe PollPaymentsServerJob do
  include ActiveJob::TestHelper

  let(:server_double) { class_double(ASP::Server) }
  let(:reader_double) { class_double(ASP::FileReader) }
  let(:double) { instance_double(ASP::FileReader) }

  before do
    stub_const("ASP::Server", server_double)
    stub_const("ASP::FileReader", reader_double)

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

  it "feeds each file to an ASP::FileReader" do
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
end
