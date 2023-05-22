# frozen_string_literal: true

Sachantque("je suis directeur de l'établissement {string}") do |name|
  @etab = FactoryBot.create(:establishment, name:)
  @principal = FactoryBot.create(:principal, establishment: @etab, provider: "developer")
  @principal.update!(uid: @principal.email)
end

Et("mon établissement n'est pas encore hydraté") do
  @etab.classes.delete_all
end

Et("mon établissement a été hydraté") do
  @classes = FactoryBot.create_list(:classe, 4, establishment: @etab)
end

Quand("je me connecte") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "developer"
    Et que je remplis "Email" avec "#{@principal.email}"
    Et que je remplis "Name" avec "#{@principal.name}"
    Et que je remplis "Uai" avec "#{@etab.uai}"
    Et que je clique sur "Sign In"
    Et que la page contient "Connexion réussie"
  )
end

Sachantque("il y a une élève {string} au sein de la classe {string}") do |name, classe|
  @etab ||= FactoryBot.create(:establishment)

  first, last = name.split # not great

  @classe = FactoryBot.create(:classe, establishment: @etab, label: classe)
  @student = FactoryBot.create(:student, classe: @classe, first_name: first, last_name: last)
end

Alors("le fil d'Ariane affiche {string}") do |path|
  components = path.split(" > ")

  breadcrumbs = page.all("nav.fr-breadcrumb li").map(&:text)

  expect(breadcrumbs).to eq components
end
