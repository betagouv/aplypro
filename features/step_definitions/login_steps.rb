# frozen_string_literal: true

def make_provider_hash(provider:, name:, email:, raw_info:)
  OmniAuth::AuthHash.new({
    provider:,
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
  })
end

Sachantque("je suis un agent de l'ASP") do
  OmniAuth.config.mock_auth[:asp] = OmniAuth::AuthHash.new(
    {
      provider: "asp",
      uid: Faker::Internet.uuid,
      info: {
        name: Faker::Name.name,
        email: Faker::Internet.email(domain: ASP::User::EMAIL_DOMAIN.first)
      }
    }
  )
end

Sachantque("je suis un agent de l'ASP avec l'email {string}") do |email|
  OmniAuth.config.mock_auth[:asp] = OmniAuth::AuthHash.new(
    {
      provider: "asp",
      uid: Faker::Internet.uuid,
      info: {
        name: Faker::Name.name,
        email: email
      }
    }
  )
end

Sachantque("je me connecte au portail ASP") do
  visit new_asp_user_session_path

  click_link_or_button "Se connecter (ASP)"
end

Sachantque("je suis un personnel académique de {string}") do |academy|
  OmniAuth.config.mock_auth[:academic] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      AplyproAcademieResp: academy
    }
  )
end

Sachantque("je suis un personnel académique des académies de {string}") do |academies_list|
  academies = academies_list.split(", ")

  OmniAuth.config.mock_auth[:academic] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      AplyproAcademieResp: academies
    }
  )
end

Sachantque("je suis un personnel académique sans validation") do
  OmniAuth.config.mock_auth[:academic] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {}
  )
end

Sachantque("je suis un personnel académique administrateur") do
  OmniAuth.config.mock_auth[:academic] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      AplyproAcademieResp: ["*"]
    }
  )
end

Sachantque("je suis un personnel MENJ de l'établissement {string}") do |uai|
  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRne: FactoryBot.build(:fredurne, uai: uai)
    }
  )
end

Sachantque("je suis un personnel MASA directeur de l'établissement {string}") do |uai|
  OmniAuth.config.mock_auth[:masa] = make_provider_hash(
    provider: "masa",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduRneResp: FactoryBot.build(:fredurneresp, uai: uai),
      FrEduFonctAdm: "DIR"
    }
  )
end

Sachantque("je me déconnecte") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Se déconnecter"
  )
end

Sachantqu("il existe un établissement {string}") do |uai|
  Establishment.find_or_create_by(uai: uai, students_provider: "sygne")
end

Sachantque("je suis un personnel MENJ directeur de l'établissement {string}") do |uai_list|
  uais = uai_list.split(", ")

  uais.each do |uai|
    step %(il existe un établissement "#{uai}")
  end

  name = Faker::Name.name
  email = Faker::Internet.email

  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: name,
    email: email,
    raw_info: {
      FrEduRneResp: uais.map { |u| FactoryBot.build(:fredurneresp, uai: u) },
      FrEduFonctAdm: "DIR"
    }
  )

  uais.each do |uai|
    establishment = Establishment.find_by(uai: uai)
    user = User.find_or_create_by!(email: email, provider: "fim") do |u|
      u.name = name
      u.uid = Faker::Alphanumeric.alpha
      u.token = "token"
      u.secret = "secret"
    end
    EstablishmentUserRole.find_or_initialize_by(user: user, establishment: establishment).update!(role: :dir)
    establishment.update!(confirmed_director: user)
  end
end

Sachantque("je suis un personnel MENJ directeur de l'établissement {string} avec l'email {string}") do |uai_list, email|
  uais = uai_list.split(", ")

  uais.each do |uai|
    step %(il existe un établissement "#{uai}")
  end

  name = Faker::Name.name

  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: name,
    email: email,
    raw_info: {
      FrEduRneResp: uais.map { |u| FactoryBot.build(:fredurneresp, uai: u) },
      FrEduFonctAdm: "DIR"
    }
  )

  uais.each do |uai|
    establishment = Establishment.find_by(uai: uai)
    user = User.find_or_create_by!(email: email, provider: "fim") do |u|
      u.name = name
      u.uid = Faker::Alphanumeric.alpha
      u.token = "token"
      u.secret = "secret"
    end
    EstablishmentUserRole.find_or_initialize_by(user: user, establishment: establishment).update!(role: :dir)
    establishment.update!(confirmed_director: user)
  end
end

Sachantque("je suis un personnel MENJ avec un accès spécifique pour l'UAI {string}") do |uai|
  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      "AplyproResp" => uai
    }
  )
end

Sachantque("je suis un personnel MENJ de l'établissement {string} avec l'email {string}") do |uai, email|
  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: email,
    raw_info: {
      FrEduRne: [uai].map { |u| FactoryBot.build(:fredurne, uai: u) }
    }
  )
end

Sachantque("je suis un personnel MENJ sans FrEduRne avec l'email {string}") do |email|
  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: email,
    raw_info: {}
  )
end

Sachantque("je suis un personnel MASA de l'établissement {string} avec l'email {string}") do |uai, email|
  OmniAuth.config.mock_auth[:masa] = make_provider_hash(
    provider: "masa",
    name: Faker::Name.name,
    email: email,
    raw_info: {
      fr_edu_rne: FactoryBot.build(:fredurne, uai:)
    }
  )
end

Sachantque("je me connecte en tant que personnel académique") do
  steps %(
    Et que je me rend sur la page d'accueil du personnel académique
    Et que je clique sur "Se connecter (MENJ)"
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
    Quand je suis un personnel MENJ directeur de l'établissement "#{uai}"
    Et que je me connecte en tant que personnel MENJ
    Et que j'autorise "marie.curie@education.gouv.fr" à rejoindre l'application
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

Alors("je n'ai pas accès aux actions de chef d'établissement") do
  steps %(
    Quand je me rends sur la page d'accueil
    Alors la page ne contient pas "Gestion des accès"
    Alors le panneau "Décisions d'attribution" ne contient pas "Éditer les décisions d'attribution"
    Alors le panneau "Demandes de paiements des PFMPs" ne contient pas "Consulter et gérer les envois en paiement"
  )
end

Sachantque("je suis un personnel MENJ de l'établissement {string} avec une délégation DELEG-CE pour APLyPro") do |uai|
  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduResDel: FactoryBot.build(:freduresdel, uai: uai)
    }
  )
end

Sachantque(
  "je suis un personnel MENJ de l'établissement {string} avec une mauvaise délégation DELEG-CE pour APLyPro"
) do |uai|
  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: Faker::Name.name,
    email: Faker::Internet.email,
    raw_info: {
      FrEduResDel: FactoryBot.build(:freduresdel, uai: uai, applicationname: "apypo")
    }
  )
end

Sachantque("j'ai désormais le rôle de directeur pour l'établissement {string}") do |uai|
  last_user = User.last

  OmniAuth.config.mock_auth[:fim] = make_provider_hash(
    provider: "fim",
    name: last_user.name,
    email: last_user.email,
    raw_info: {
      FrEduResDel: FactoryBot.build(:freduresdel, uai: uai),
      FrEduRneResp: [FactoryBot.build(:fredurneresp, uai: uai)],
      FrEduFonctAdm: "DIR"
    }
  )
end
