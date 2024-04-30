# frozen_string_literal: true

require "rails_helper"

RSpec.describe PollPaymentsServerJob do
  include ActiveJob::TestHelper

  let(:server_double) { class_double(ASP::Server) }
  let(:saver_double) { instance_double(ASP::FileSaver) }
  let(:mock_file) { Tempfile.create }
  let(:basename) { File.basename(mock_file) }

  before do
    stub_const("ASP::Server", server_double)
    stub_const("ASP::FileSaver", class_double(ASP::FileSaver, new: saver_double))

    allow(Dir).to receive(:each_child).and_yield(basename)

    allow(saver_double).to receive(:persist_file!)

    allow(server_double).to receive(:get_all_files!).and_return(File.dirname(mock_file))
    allow(server_double).to receive(:remove_file!)
  end

  it "calls the get_all_files! ASP::Server method" do
    perform_enqueued_jobs(only: described_class) { described_class.perform_later }

    expect(server_double).to have_received(:get_all_files!)
  end

  it "feeds each file to an ASP::FileSaver" do
    perform_enqueued_jobs(only: described_class) { described_class.perform_later }

    expect(saver_double).to have_received(:persist_file!)
  end

  it "enqueues a job to process the file" do
    expect { described_class.perform_now }
      .to have_enqueued_job(ProcessASPResponseFileJob).once.with(basename)
  end

  context "when the original request can't be found" do
    before do
      allow(saver_double).to receive(:persist_file!).and_raise ASP::Errors::UnmatchedResponseFile
    end

    it "does not remove the file off the server" do
      suppress(ASP::Errors::UnmatchedResponseFile) do
        described_class.perform_now

        expect(server_double).not_to have_received(:remove_file!)
      end
    end
  end
end
