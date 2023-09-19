# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Cas < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "cas"

      # You may specify that your strategy should use PKCE by setting
      # the pkce option to true: https://tools.ietf.org/html/rfc7636
      option :pkce, false

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info["id"] }

      info do
        attrs = raw_info["attributes"]

        {
          name: attrs["display_name"],
          email: attrs["mail"]
        }
      end

      extra do
        {
          "raw_info" => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("profile").parsed
      end
    end
  end
end
