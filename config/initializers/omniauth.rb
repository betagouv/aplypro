# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

# rubocop:disable Metrics/BlockLength
Rails.application.config.middleware.use OmniAuth::Builder do
  unless Rails.env.production?
    portals = ["MENJ (FIM)"]

    portals.push("MASA (CAS)") if Rails.env.development?

    provider :developer,
             path_prefix: "/users/auth",
             fields: [
               :uai,
               :email,
               { "Portail de connexion" => portals },
               { "Role assumé" => ["Personnel de direction", "Personnel autorisé"] },
               { callback: %w[aplypro insider] }
             ]
  end

  provider :openid_connect, {
    name: :fim,
    path_prefix: "/users/auth",
    scope: ENV.fetch("APLYPRO_FIM_SCOPE"),
    response_type: :code,
    issuer: ENV.fetch("APLYPRO_FIM_ISSUER"),
    discovery: true,
    client_options: {
      redirect_uri: ENV.fetch("APLYPRO_FIM_REDIRECT_URI"),
      host: ENV.fetch("APLYPRO_FIM_HOST"),
      identifier: ENV.fetch("APLYPRO_FIM_CLIENT_ID"),
      secret: ENV.fetch("APLYPRO_FIM_CLIENT_SECRET")
    }
  }

  provider :cas, ENV.fetch("APLYPRO_CAS_CLIENT_ID"), ENV.fetch("APLYPRO_CAS_CLIENT_SECRET"), {
    name: :masa,
    path_prefix: "/users/auth",
    token_params: {
      redirect_uri: ENV.fetch("APLYPRO_CAS_REDIRECT_URI")
    },
    client_options: {
      site: ENV.fetch("APLYPRO_CAS_SITE_ROOT"),
      authorize_url: "authorize",
      token_url: "accessToken",
      auth_scheme: :request_body,
      redirect_uri: ENV.fetch("APLYPRO_CAS_REDIRECT_URI")
    }
  }

  provider :openid_connect, {
    name: :asp,
    scope: ENV.fetch("APLYPRO_ASP_OIDC_SCOPE"),
    discovery: true,
    issuer: ENV.fetch("APLYPRO_ASP_OIDC_ISSUER"),
    client_options: {
      host: ENV.fetch("APLYPRO_ASP_OIDC_HOST"),
      redirect_uri: ENV.fetch("APLYPRO_ASP_OIDC_REDIRECT_URI"),
      identifier: ENV.fetch("APLYPRO_ASP_OIDC_CLIENT_ID"),
      secret: ENV.fetch("APLYPRO_ASP_OIDC_CLIENT_SECRET")
    }
  }
end
# rubocop:enable Metrics/BlockLength
