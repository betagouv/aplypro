# frozen_string_literal: true

OpenIDConnect.http_config do |faraday|
  faraday.response :raise_error
end
