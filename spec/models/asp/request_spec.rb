# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::Request do
  let(:fichier_double) { class_double(ASP::Entities::Fichier) }
  let(:double) { instance_double(ASP::Entities::Fichier) }

  before do
    stub_const("ASP::Entities::Fichier", fichier_double)

    allow(double).to receive_messages(to_xml: "test io", filename: "test filename")

    allow(fichier_double).to receive(:new).and_return(double)
  end

  describe ".from_payments" do
    subject(:factory) { described_class.with_payments(Payment.all, ASP::Entities::Fichier) }

    let!(:payment) { create(:payment) }

    it "creates a new instance" do
      expect { factory }.to change(described_class, :count).by(1)
    end

    it "attaches the file's content" do
      instance = factory

      expect(instance.file).to be_attached
    end

    it "updates the payment's request reference" do
      expect { factory }.to(change { payment.reload.asp_request_id })
    end
  end

  describe "#send!" do
    let(:request) { create(:asp_request) }
    let(:server_double) { class_double(ASP::Server) }

    before do
      allow(server_double).to receive(:drop_file!)

      request.file.attach(io: StringIO.new("some XML"), filename: "foobar.xml")
    end

    it "calls drop_file! on the server object" do
      request.send!(server_double)

      expect(server_double).to have_received(:drop_file!).with(io: "some XML", path: "foobar.xml")
    end

    it "updates the sent_at attribute" do
      expect { request.send!(server_double) }.to change(request, :sent_at)
    end
  end
end
