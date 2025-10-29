# frozen_string_literal: true

Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

Rack::Attack.throttle(
  "req/ip",
  limit: ->(_req) { ENV.fetch("RATE_LIMIT_PER_IP", "300").to_i },
  period: ->(_req) { ENV.fetch("RATE_LIMIT_PERIOD_MINUTES", "5").to_i.minutes },
  &:ip
)

Rack::Attack.blocklist("block scanners") do |req|
  req.user_agent.to_s.match?(/nmap|masscan|nikto|sqlmap|dirbuster/i)
end
