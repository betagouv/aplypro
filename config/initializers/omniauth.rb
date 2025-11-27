# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

# Mitigate CVE-2015-9284
OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)

# rubocop:disable Metrics/BlockLength
Rails.application.config.middleware.use OmniAuth::Builder do
  unless Rails.env.production?
    portals = ["MENJ (FIM)"]

    portals.push("MASA (Hub Partenaire)") if Rails.env.development?

    provider :developer,
             path_prefix: "/users/auth",
             fields: [
               :uai,
               :email,
               { "Portail de connexion" => portals },
               { "Role assumé" => ["Personnel de direction", "Personnel autorisé"] }
             ]

    provider :developer,
             name: :asp_developer,
             path_prefix: "/auth",
             fields: [
               :email,
               { "Portail de connexion" => ["ASP"] }
             ]

    provider :developer,
             name: :academic_developer,
             path_prefix: "/auth",
             fields: %i[academy_code email]
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

  provider :openid_connect, {
    name: :academic,
    path_prefix: "/auth",
    scope: ENV.fetch("APLYPRO_ACADEMIC_OIDC_SCOPE"),
    response_type: :code,
    issuer: ENV.fetch("APLYPRO_ACADEMIC_OIDC_ISSUER"),
    discovery: true,
    client_options: {
      host: ENV.fetch("APLYPRO_ACADEMIC_OIDC_HOST"),
      redirect_uri: ENV.fetch("APLYPRO_ACADEMIC_OIDC_REDIRECT_URI"),
      identifier: ENV.fetch("APLYPRO_ACADEMIC_OIDC_CLIENT_ID"),
      secret: ENV.fetch("APLYPRO_ACADEMIC_OIDC_CLIENT_SECRET")
    }
  }

  provider :openid_connect, {
    name: :asp,
    path_prefix: "/auth",
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

  provider :openid_connect, {
    name: :masa,
    path_prefix: "/users/auth",
    scope: ENV.fetch("APLYPRO_HUB_PARTENAIRE_OIDC_SCOPE"),
    response_type: :code,
    issuer: ENV.fetch("APLYPRO_HUB_PARTENAIRE_OIDC_ISSUER"),
    client_options: {
      host: ENV.fetch("APLYPRO_HUB_PARTENAIRE_OIDC_HOST"),
      redirect_uri: ENV.fetch("APLYPRO_HUB_PARTENAIRE_OIDC_REDIRECT_URI"),
      identifier: ENV.fetch("APLYPRO_HUB_PARTENAIRE_OIDC_CLIENT_ID"),
      secret: ENV.fetch("APLYPRO_HUB_PARTENAIRE_OIDC_CLIENT_SECRET")
    }
  }
end
# rubocop:enable Metrics/BlockLength
