# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcessASPResponseFileJob do
  include ActiveJob::TestHelper

  let(:asp_request) { instance_double(ASP::Request) }

  before do
    filename_double = instance_double(ASP::Filename, to_s: "original.csv", kind: "test")

    stub_const("ASP::Filename", class_double(ASP::Filename, new: filename_double))

    allow(asp_request).to receive(:parse_response_file!)

    # NOTE: this is ActiveRecord API we're fine
    # rubocop:disable Rspec/MessageChain
    allow(ActiveStorage::Blob)
      .to receive_message_chain(:find_by, :attachments, :first, :record)
      .and_return(asp_request)
    # rubocop:enable Rspec/MessageChain
  end

  it "uses ASP::Filename to find the record that holds the filename" do
    described_class.perform_now("foobar")

    expect(ActiveStorage::Blob)
      .to have_received(:find_by).with("active_storage_blobs.filename": "original.csv")
  end

  it "calls parse_response_file! on the resulting record" do
    described_class.perform_now("foobar")

    expect(asp_request).to have_received(:parse_response_file!).with("test")
  end
end
