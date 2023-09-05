# frozen_string_literal: true

def make_fredurne(uai, activity = "ADF")
  [uai, "UAJ", "PU", activity, "T3", "LYC", "340"].join("$")
end

def make_fim_hash(name:, email:, raw_info:)
  OmniAuth::AuthHash.new(
    {
      provider: "fim",
      uid: Faker::String.random,
      credentials: {
        token: "test token"
      },
      info: {
        name:,
        email:
      },
      extra: {
        raw_info:
      }
    }
  )
end

Sachantque("je suis un personnel MENJ directeur de l'établissement {string}") do |uai|
  uais = uai.split(", ")

  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRneResp: uais.map { |u| make_fredurne(u) }
    }
  )
end

Sachantque("je me connecte en tant que personnel MENJ") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "fim"
  )
end
