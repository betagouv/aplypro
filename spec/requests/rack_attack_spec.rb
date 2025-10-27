# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack" do
  before do
    Rack::Attack.enabled = true
    stub_const("Aplypro::RATE_LIMIT_PER_IP", 5)
    Rack::Attack.throttles.clear
    Rack::Attack.throttle("req/ip", limit: Aplypro::RATE_LIMIT_PER_IP, period: 5.minutes, &:ip)
  end

  around do |example|
    Rack::Attack.cache.store.clear
    example.run
    Rack::Attack.cache.store.clear
  end

  describe "throttle by ip" do
    it "allows requests under the limit" do
      5.times do
        get "/legal"
        expect(response).not_to have_http_status(:too_many_requests)
      end
    end

    it "blocks requests over the limit" do
      6.times { get "/legal" }
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "block scanners" do
    it "allows legitimate requests" do
      get "/legal"
      expect(response).not_to have_http_status(:forbidden)
    end

    it "blocks nmap" do
      get "/legal", headers: { "User-Agent" => "nmap" }
      expect(response).to have_http_status(:forbidden)
    end

    it "blocks masscan" do
      get "/legal", headers: { "User-Agent" => "masscan/1.0" }
      expect(response).to have_http_status(:forbidden)
    end

    it "blocks sqlmap" do
      get "/legal", headers: { "User-Agent" => "sqlmap/1.0" }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
