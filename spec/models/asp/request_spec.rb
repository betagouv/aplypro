# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::Request do
  subject(:request) do
    described_class.new(
      asp_payment_requests: create_list(:asp_payment_request, 2, :ready)
    )
  end

  let(:fichier_double) { class_double(ASP::Entities::Fichier) }
  let(:double) { instance_double(ASP::Entities::Fichier) }
  let(:server_double) { class_double(ASP::Server) }

  before do
    stub_const("ASP::Server", server_double)

    allow(server_double).to receive(:drop_file!)

    stub_const("ASP::Entities::Fichier", fichier_double)

    allow(double).to receive_messages(to_xml: "test io", filename: "test filename", validate!: "")

    allow(fichier_double).to receive(:new).and_return(double)
  end

  describe "validations" do
    it { is_expected.to validate_length_of(:asp_payment_requests).is_at_most(7000) }
  end

  describe "scopes" do
    let(:request) { create(:asp_request, :sent, sent_at: sent_at) }

    describe "sent_today" do
      subject { described_class.sent_today }

      context "when there's a request today" do
        let(:sent_at) { Date.current }

        it { is_expected.to include(request) }
      end

      context "when the request is from yesterday" do
        let(:sent_at) { Date.yesterday }

        it { is_expected.not_to include(request) }
      end
    end

    describe "sent_this_week" do
      subject { described_class.sent_this_week }

      before do
        create_list(:asp_request, 2, :sent, sent_at: 1.week.ago)
        create_list(:asp_request, 3, :sent, sent_at: Date.current)
        create_list(:asp_request, 4, :sent, sent_at: 2.weeks.from_now)
      end

      it { is_expected.to have(3).requests }
    end
  end

  describe ".send!" do
    it "moves the payment requests to sent" do
      expect { request.send! }.to change(ASP::PaymentRequest.in_state(:sent), :count).from(0).to(2)
    end

    it "updates the sent_at timestamp" do
      expect { request.send! }.to change(request, :sent_at)
    end

    context "with an existing rejects file" do
      before { request.rejects_file.attach(io: StringIO.new("rejects"), filename: "rejects") }

      it "refuses to run" do
        expect { request.send! }.to raise_error ASP::Errors::RerunningParsedRequest
      end
    end

    context "with an existing integrations file" do
      before { request.integrations_file.attach(io: StringIO.new("rejects"), filename: "rejects") }

      it "refuses to run" do
        expect { request.send! }.to raise_error ASP::Errors::RerunningParsedRequest
      end
    end

    shared_examples "does not persist anything" do
      it "does not update the sent_at timestamp" do
        expect { request.send! rescue RuntimeError } # rubocop:disable Style/RescueModifier
          .not_to(change(request, :sent_at))
      end

      it "does not update the payment requests" do
        expect { request.send! rescue RuntimeError } # rubocop:disable Style/RescueModifier
          .not_to(change(ASP::PaymentRequest.in_state(:sent), :count))
      end
    end

    context "when something in the XML formatting goes wrong" do
      before { allow(double).to receive(:to_xml).and_raise }

      include_examples "does not persist anything"
    end

    context "when the XML is not valid" do
      before { allow(double).to receive(:validate!).and_raise }

      include_examples "does not persist anything"
    end

    context "when the server can't upload the file" do
      before { allow(server_double).to receive(:drop_file!).and_raise }

      include_examples "does not persist anything"
    end

    context "when the rerun parameter is passed" do
      subject(:rerun) { request.send!(rerun: true) }

      before { request.send! }

      it "can process already-sent requests" do
        expect { rerun }.not_to raise_error
      end

      it "includes all the previous requests" do
        expect(ASP::Entities::Fichier).to have_received(:new).with(request.asp_payment_requests)

        rerun
      end

      it "generates a new file" do
        expect { rerun }.to change(request.file, :filename)
      end

      it "update the sent timestamp" do
        expect { rerun }.to change(request, :sent_at)
      end
    end

    describe ".total_requests_left" do
      subject(:allowance) { described_class.total_requests_left }

      before do
        Timecop.travel(2.weeks.ago) do
          create_list(:asp_payment_request, 3, :sent)
        end

        create_list(:asp_payment_request, 1, :sent)
      end

      it "accounts all requests sent this week" do
        expect(allowance).to eq 99_999
      end
    end
  end
end
