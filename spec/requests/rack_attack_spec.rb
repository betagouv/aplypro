# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack" do
  let(:rate_limit) { 5 }
  let(:rate_period) { 5 }

  before do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store.clear
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("RATE_LIMIT_PER_IP", "600").and_return(rate_limit.to_s)
    allow(ENV).to receive(:fetch).with("RATE_LIMIT_PERIOD_MINUTES", "5").and_return(rate_period.to_s)
  end

  after do
    Rack::Attack.cache.store.clear
    Rack::Attack.enabled = false
  end

  describe "throttle by ip" do
    it "allows requests under the limit" do
      rate_limit.times do
        get "/legal"
        expect(response).not_to have_http_status(:too_many_requests)
      end
    end

    it "blocks requests over the limit" do
      (rate_limit + 1).times { get "/legal" }
      expect(response).to have_http_status(:too_many_requests)
    end

    it "sends notification to Sentry when throttling" do
      allow(Sentry).to receive(:capture_message)
      (rate_limit + 1).times { get "/legal" }

      expected_extra = hash_including(discriminator: "127.0.0.1", matched: "req/ip", ip: "127.0.0.1", path: "/legal")
      expect(Sentry).to have_received(:capture_message).with(
        "Rate limit exceeded", hash_including(level: :warning, extra: expected_extra)
      )
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
