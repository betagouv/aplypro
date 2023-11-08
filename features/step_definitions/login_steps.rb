# frozen_string_literal: true

def make_fim_hash(name:, email:, raw_info:)
  OmniAuth::AuthHash.new(
    {
      provider: "fim",
      uid: email,
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

def make_cas_hash(name:, email:, raw_info:)
  OmniAuth::AuthHash.new(
    {
      provider: "masa",
      uid: Faker::Alphanumeric.alpha(number: 10),
      credentials: {
        token: "test token"
      },
      info: {
        name:,
        email:
      },
      extra: {
        raw_info: {
          attributes: raw_info
        }
      }
    }
  )
end

Sachantque("je suis un personnel MENJ de l'établissement {string}") do |uai|
  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRne: FactoryBot.build(:fredurne, uai: uai)
    }
  )
end

Sachantque("je suis un personnel MASA directeur de l'établissement {string}") do |uai|
  OmniAuth.config.mock_auth[:masa] = make_cas_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      fr_edu_rne_resp: FactoryBot.build(:fredurneresp, uai: uai),
      fr_edu_fonct_adm: "DIR"
    }
  )
end

Sachantque("je me déconnecte") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se déconnecter"
  )
end

Sachantque("je suis un personnel MENJ directeur de l'établissement {string}") do |uai|
  uais = uai.split(", ")

  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRneResp: uais.map { |u| FactoryBot.build(:fredurneresp, uai: u) },
      FrEduFonctAdm: "DIR"
    }
  )
end

Sachantque("je suis un personnel MENJ avec un accès spécifique pour l'UAI {string}") do |uai|
  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      "AplyproResp" => uai
    }
  )
end

Sachantque("je suis un personnel MENJ de l'établissement {string} avec l'email {string}") do |uai, email|
  OmniAuth.config.mock_auth[:fim] = make_fim_hash(
    name: Faker::Name.name,
    email: email,
    raw_info: {
      FrEduRne: [uai].map { |u| FactoryBot.build(:fredurne, uai: u) }
    }
  )
end

Sachantque("je suis un personnel MASA de l'établissement {string} avec l'email {string}") do |uai, email|
  OmniAuth.config.mock_auth[:masa] = make_cas_hash(
    name: Faker::Name.name,
    email: email,
    raw_info: {
      fr_edu_rne: FactoryBot.build(:fredurne, uai:)
    }
  )
end

Sachantque("je me connecte en tant que personnel MENJ") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se connecter (MENJ)"
  )
end

Sachantque("je me connecte en tant que personnel MASA") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se connecter (MASA)"
  )
end

Sachantque("je passe l'écran d'accueil") do
  steps %(Quand je clique sur "Continuer")
end

Sachantque("je me connecte en tant que personnel autorisé de l'établissement {string}") do |uai|
  steps %(
    Quand j'autorise "marie.curie@education.gouv.fr" à rejoindre l'application
    Et que je me déconnecte
    Et que je suis un personnel MENJ de l'établissement "#{uai}" avec l'email "marie.curie@education.gouv.fr"
    Et que je me connecte en tant que personnel MENJ
  )
end

Sachantque("l'accès est limité aux UAIs {string}") do |str|
  ENV.update("APLYPRO_RESTRICTED_ACCESS" => str)
end

Alors("la page affiche une erreur d'authentification") do
  steps %(
    Alors la page contient "Erreur d'authentification"
  )
end
