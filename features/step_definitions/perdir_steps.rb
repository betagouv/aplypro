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

Sachantque(
  "il y a un(e) élève {string} au sein de la classe {string} pour une formation {string}"
) do |name, classe, mef|
  @etab ||= FactoryBot.create(:establishment)

  first, last = name.split # not great

  @mef = FactoryBot.create(:mef, label: mef)
  @classe = FactoryBot.create(:classe, establishment: @etab, label: classe, mef: @mef)
  @student = FactoryBot.create(:student, classe: @classe, first_name: first, last_name: last)
end

Alors("le fil d'Ariane affiche {string}") do |path|
  components = path.split(" > ")

  breadcrumbs = page.all("nav.fr-breadcrumb li").map(&:text)

  expect(breadcrumbs).to eq components
end

Quand("l'élève n'a réalisé aucune PFMP") do
  @student.current_schooling.pfmps.delete_all
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
  steps %(
    Quand je consulte le profil de l'élève "#{name}"
    Et que je clique sur "Renseigner les coordonnées bancaires"
    Et que je renseigne des coordonnées bancaires
  )
end

Quand("je consulte la liste des classes") do
  visit classes_path
end

Quand("je renseigne une PFMP de {int} jours pour {string}") do |days, name|
  steps %(
    Quand je consulte le profil de l'élève "#{name}"
    Quand je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "20/03/2023"
    Et que je remplis "Nombre de jours effectués" avec "#{days}"
    Et que je clique sur "Enregistrer"
  )
end

Sachantque(
  "mon établissement propose une formation {string} rémunérée à {int} euros par jour et plafonnée à {int} euros par an"
) do |mef, rate, cap|
  mef = FactoryBot.create(:mef, code: mef, label: mef, short: mef)
  mef.wage.update!(daily_rate: rate, yearly_cap: cap)
end

Quand("je vais voir la classe {string}") do |label|
  visit class_path(Classe.find_by(label:))
end

Alors("tous les élèves ont une PFMP du {string} au {string}") do |start_date, end_date|
  expect(@classe.students.all? { |s| s.pfmps.exists?(start_date:, end_date:) })
end

# FIXME: we're relying on global state here via the @student variable
# but we should keep using a name reference to do it via the user
# interface instead of prying directly at the model.
Quand("je valide la dernière PFMP de l'élève") do
  @student.pfmps.last.transition_to!(:validated)
end

Sachantque("je renseigne une PFMP provisoire pour {string}") do |name|
  steps %(
    Quand je consulte le profil de l'élève "#{name}"
    Et que je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "20/03/2023"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je consulte la liste des PFMPs {string}") do |tab|
  steps %(
    Quand je clique sur "Liste des PFMPs"
    Et que je clique sur "#{tab}"
  )
end

Quand("je renseigne {int} jours pour la dernière PFMP de {string}") do |days, name|
  steps %(
    Quand je consulte le profil de l'élève "#{name}"
    Et que je clique sur "Voir la PFMP"
    Et que je remplis "Nombre de jours" avec "#{days}"
    Et que je clique sur "Modifier la PFMP"
  )
end
