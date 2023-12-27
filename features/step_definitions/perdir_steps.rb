# frozen_string_literal: true

# hacks
def find_student_by_full_name(name)
  Student.all.find { |s| s.full_name == name }
end

Et("mon établissement n'est pas encore hydraté") do
  @etab.classes.delete_all
end

Et("mon établissement a été hydraté") do
  @classes = FactoryBot.create_list(:classe, 4, establishment: @etab)
end

Sachantque(
  "il y a un(e) élève {string} au sein de la classe {string} pour une formation {string}"
) do |name, classe, mef|
  @etab ||= User.last.establishment

  first, last = name.split # not great
  @mef = Mef.find_by(label: mef) ||
         FactoryBot.create(:mef, label: mef)
  @classe = Classe.find_by(mef: @mef, establishment: @etab) ||
            FactoryBot.create(:classe, establishment: @etab, label: classe, mef: @mef)
  @student = FactoryBot.create(:student, first_name: first, last_name: last)
  @student.schoolings.create!(classe: @classe)
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

Quand("je renseigne les coordonnées bancaires de l'élève {string} de la classe {string}") do |name, label|
  steps %(
    Quand je vais voir la classe "#{label}"
    Et que je clique sur "Voir le profil de #{name}"
    Et que je clique sur "Saisir les coordonnées bancaires"
    Et que je renseigne des coordonnées bancaires
  )
end

Quand("l'élève {string} a déjà des coordonnées bancaires") do |name|
  student = find_student_by_full_name(name)
  FactoryBot.create(:rib, student: student)
end

Quand("je clique sur {string} dans le menu principal") do |item|
  within("nav#main-nav") do
    click_link(item)
  end
end

Quand("je consulte la liste des classes") do
  steps %(Quand je clique sur "Élèves" dans le menu principal)
end

Quand("je vais voir le profil de {string} dans la classe de {string}") do |name, label|
  steps %(
    Quand je consulte la classe de "#{label}"
    Et que je clique sur "Voir le profil de #{name}"
  )
end

Quand("je renseigne une PFMP de {int} jours") do |days|
  steps %(
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
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je consulte la liste des classes
    Et je clique sur "Voir la classe" dans la rangée "#{label}"
  )
end

Alors("tous les élèves ont une PFMP du {string} au {string}") do |start_date, end_date|
  expect(@classe.students.all? { |s| s.pfmps.exists?(start_date:, end_date:) }).to be_truthy
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
    Et que je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "#{days}"
    Et que je clique sur "Modifier la PFMP"
  )
end

Quand(
  "je saisis une PFMP pour toute la classe {string} avec les dates {string} et {string}"
) do |classe, date_debut, date_fin|
  steps %(
    Quand je vais voir la classe "#{classe}"
    Et que je clique sur "Saisir une PFMP pour toute la classe"
    Et que je remplis "Date de début" avec "#{date_debut}"
    Et que je remplis "Date de fin" avec "#{date_fin}"
    Et que je clique sur "Enregistrer"
  )
end

Alors("il y a un compte utilisateur enregistré") do
  expect(User.count).to eq 1
end

Quand("je n'ai pas encore vu l'écran d'accueil") do
  @etab.users.directors.first.update!(welcomed: false)
end

Sachantque("j'autorise {string} à rejoindre l'application") do |email|
  steps %(
    Quand je consulte la liste des invitations
    Et que je clique sur "Autoriser un nouvel email"
    Et que je remplis "Email" avec "#{email}"
    Et que je clique sur "Autoriser l'email"
  )
end

Lorsque("je consulte la liste des invitations") do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "Gestion des accès"
  )
end

Quand("je consulte la classe de {string}") do |classe_label|
  steps %(
    Quand je consulte la liste des classes
    Et que je clique sur "Voir la classe" dans la rangée "#{classe_label}"
  )
end

Alors("je peux voir l'écran d'accueil") do
  step('la page contient "Bienvenue sur APLyPro"')
end
