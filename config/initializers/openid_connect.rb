# frozen_string_literal: true

require "omniauth_openid_connect"

OpenIDConnect.http_config do |faraday|
  faraday.response :raise_error
end
