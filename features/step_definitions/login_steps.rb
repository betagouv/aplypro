# frozen_string_literal: true

def make_fredurneresp(uai, activity = "ADF")
  [uai, "UAJ", "PU", activity, "T3", "LYC", "340"].join("$")
end

def make_fredurne(uai)
  [uai, "UAJ", "PU", "ADM", uai, "T3", "LYC", "340"].join("$")
end

def make_fim_hash(name:, email:, raw_info:)
  OmniAuth::AuthHash.new(
    {
      provider: "fim",
      uid: Faker::Alphanumeric.alpha(number: 10),
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

Sachantque("je suis un personnel MENJ de l'établissement {string}") do |uai|
  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRne: make_fredurne(uai)
    }
  )
end

Sachantque("je suis un personnel MENJ directeur de l'établissement {string}") do |uai|
  uais = uai.split(", ")

  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRneResp: uais.map { |u| make_fredurneresp(u) }
    }
  )
end

Sachantque("je me connecte en tant que personnel MENJ") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Accéder au portail de connexion"
  )
end
