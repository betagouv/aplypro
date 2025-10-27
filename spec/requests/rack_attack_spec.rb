# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack" do
  before do
    Rack::Attack.cache.store.clear
    Rack::Attack.enabled = true
  end

  after do
    Rack::Attack.cache.store.clear
  end

  describe "throttle by ip" do
    let(:limit) { 300 }

    it "allows requests under the limit" do
      limit.times do
        get root_path
        expect(response).not_to have_http_status(:too_many_requests)
      end
    end

    it "blocks requests over the limit" do
      (limit + 1).times { get root_path }
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "block scanners" do
    it "allows legitimate requests" do
      get root_path
      expect(response).not_to have_http_status(:forbidden)
    end

    it "blocks nmap" do
      get root_path, headers: { "User-Agent" => "nmap" }
      expect(response).to have_http_status(:forbidden)
    end

    it "blocks masscan" do
      get root_path, headers: { "User-Agent" => "masscan/1.0" }
      expect(response).to have_http_status(:forbidden)
    end

    it "blocks sqlmap" do
      get root_path, headers: { "User-Agent" => "sqlmap/1.0" }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
