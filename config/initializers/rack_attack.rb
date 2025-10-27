# frozen_string_literal: true

Rack::Attack.cache.store = ActiveSupport::Cache.lookup_store(:redis_cache_store)

Rack::Attack.throttle("req/ip", limit: 300, period: 5.minutes, &:ip)

Rack::Attack.blocklist("block scanners") do |req|
  req.user_agent.to_s.match?(/nmap|masscan|nikto|sqlmap|dirbuster/i)
end
