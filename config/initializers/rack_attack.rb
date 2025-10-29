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

Rack::Attack.throttled_responder = lambda do |request|
  match_data = request.env["rack.attack.match_data"]

  Sentry.capture_message(
    "Rate limit exceeded",
    level: :warning,
    extra: {
      discriminator: request.env["rack.attack.match_discriminator"],
      matched: request.env["rack.attack.matched"],
      count: match_data[:count],
      limit: match_data[:limit],
      period: match_data[:period],
      ip: request.ip,
      path: request.path,
      user_agent: request.user_agent
    }
  )

  [429, { "Content-Type" => "text/plain" }, ["Too Many Requests\n"]]
end
