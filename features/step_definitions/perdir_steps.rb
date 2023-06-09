# frozen_string_literal: true

# hacks
def find_student_by_full_name(name)
  Student.all.find { |s| s.full_name == name }
end

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

Quand("l'élève n'a réalisé aucune PFMP") do
  @student.pfmps.delete_all
end

Alors("l'élève a {int} PFMP") do |count|
  expect(@student.pfmps.count).to eq count
end

# FIXME: this is hacks
Quand("je consulte le profil de l'élève {string}") do |name|
  student = find_student_by_full_name(name)

  visit class_student_path(student.classe, student)
end

Quand("je renseigne les coordonnées bancaires de l'élève {string} de la classe {string}") do |name, _label|
  rib = FactoryBot.build(:rib)

  steps %(
    Quand je consulte le profil de l'élève "#{name}"
    Et que je clique sur "Renseigner les coordonnées bancaires"
    Et que je remplis "IBAN" avec "#{rib.iban}"
    Et que je remplis "BIC" avec "#{rib.bic}"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je consulte la liste des classes") do
  visit classes_path
end

Quand("je renseigne une PFMP pour {string}") do |name|
  steps %(
    Quand je consulte le profil de l'élève "#{name}"
    Quand je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "20/03/2023"
    Et que je clique sur "Enregistrer"
  )
end
