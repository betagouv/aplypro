# frozen_string_literal: true

module Aplypro
  RATE_LIMIT_PER_IP = ENV.fetch("RATE_LIMIT_PER_IP", 300).to_i
end

Rack::Attack.cache.store = ActiveSupport::Cache.lookup_store(:redis_cache_store)

Rack::Attack.throttle("req/ip", limit: Aplypro::RATE_LIMIT_PER_IP, period: 5.minutes, &:ip)

Rack::Attack.blocklist("block scanners") do |req|
  req.user_agent.to_s.match?(/nmap|masscan|nikto|sqlmap|dirbuster/i)
end
