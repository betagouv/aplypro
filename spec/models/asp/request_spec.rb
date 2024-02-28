# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::Request do
  subject(:request) { described_class.new(asp_payment_requests: payment_requests) }

  let(:payment_requests) { create_list(:asp_payment_request, 3, :ready) }

  let(:fichier_double) { class_double(ASP::Entities::Fichier) }
  let(:double) { instance_double(ASP::Entities::Fichier) }
  let(:server_double) { class_double(ASP::Server) }

  before do
    stub_const("ASP::Server", server_double)

    allow(server_double).to receive(:drop_file!)

    stub_const("ASP::Entities::Fichier", fichier_double)

    allow(double).to receive_messages(to_xml: "test io", filename: "test filename")

    allow(fichier_double).to receive(:new).and_return(double)
  end

  describe ".send!" do
    it "moves the payment requests to sent" do
      expect { request.send! }.to change { payment_requests.last.reload.current_state }.from("ready").to("sent")
    end

    it "updates the sent_at timestamp" do
      expect { request.send! }.to change(request, :sent_at)
    end

    it "sets the request_id on the target payment requests" do
      request.send!

      expect(payment_requests.map(&:asp_request_id).uniq).to contain_exactly(request.id)
    end

    shared_examples "does not persist anything" do
      it "does not update the sent_at timestamp" do
        expect { request.send! rescue RuntimeError } # rubocop:disable Style/RescueModifier
          .not_to(change(request, :sent_at))
      end

      it "does not update the payment requests" do
        expect { request.send! rescue RuntimeError } # rubocop:disable Style/RescueModifier
          .not_to(change(payment_requests.last, :current_state))
      end
    end

    context "when something in the XML formatting goes wrong" do
      before { allow(double).to receive(:to_xml).and_raise }

      include_examples "does not persist anything"
    end

    context "when the server can't upload the file" do
      before { allow(server_double).to receive(:drop_file!).and_raise }

      include_examples "does not persist anything"
    end
  end
end
