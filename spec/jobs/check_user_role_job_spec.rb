# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckUserRoleJob do
  let(:user) { create(:user, email: "test@example.com") }
  let(:job) { described_class.new }
  let(:rua_client) { instance_double(Omogen::Rua) }

  before do
    allow(Omogen::Rua).to receive(:new).and_return(rua_client)
    job.user = user
  end

  describe "#perform" do
    it "finds the user and checks their role" do
      allow(User).to receive(:find).with(user.id).and_return(user)
      allow(job).to receive(:check_role)

      job.perform(user.id)

      expect(job).to have_received(:check_role)
    end
  end

  describe "#check_role" do
    context "when RUA returns valid data" do
      before do
        allow(job).to receive(:dir?).and_return(true)
      end

      it "returns the result of dir? check" do
        expect(job.check_role).to be true
      end
    end

    context "when errors occur" do
      before do
        allow(job).to receive(:dir?).and_raise(JSON::ParserError)
      end

      it "returns false" do
        expect(job.check_role).to be false
      end
    end
  end

  describe "#rua_info" do
    context "when RUA returns exactly one result" do
      let(:rua_response) { [{ "some" => "data" }] }

      before do
        allow(rua_client).to receive(:synthese_info)
          .with(user.email)
          .and_return(rua_response)
      end

      it "returns the first result" do
        expect(job.rua_info).to eq(rua_response[0])
      end
    end

    context "when RUA returns no results or multiple results" do
      before do
        allow(rua_client).to receive(:synthese_info)
          .with(user.email)
          .and_return([])
      end

      it "raises NoRuaResultError" do
        expect { job.rua_info }.to raise_error(described_class::NoRuaResultError)
      end
    end
  end

  describe "#last_operational_role" do
    context "when operational roles exist" do
      let(:operational_role) { { "role" => "some_role" } }

      before do
        allow(job).to receive(:rua_info)
          .and_return({ "affectationsOperationnelles" => [operational_role] })
      end

      it "returns the first operational role" do
        expect(job.last_operational_role).to eq(operational_role)
      end
    end

    context "when no operational roles exist" do
      before do
        allow(job).to receive(:rua_info)
          .and_return({ "affectationsOperationnelles" => [] })
      end

      it "raises NoLastOperationalRoleError" do
        expect { job.last_operational_role }.to raise_error(described_class::NoLastOperationalRoleError)
      end
    end
  end

  describe "#dir?" do
    let(:operational_role) do
      { "specialiteEmploiType" => Omogen::Rua::DIR_EMPLOI_TYPE }
    end

    before do
      allow(job).to receive(:last_operational_role).and_return(operational_role)
    end

    it "returns true when specialiteEmploiType matches director value" do
      expect(job.dir?).to be true
    end

    it "returns false when specialiteEmploiType doesn't match director value" do
      operational_role["specialiteEmploiType"] = "something_else"
      expect(job.dir?).to be false
    end
  end
end
