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
  @etab ||= User.last.selected_establishment

  first_name, last_name = name.split # not great
  @mef = Mef.find_by(label: mef) ||
         FactoryBot.create(:mef, label: mef)
  @classe = Classe.find_by(mef: @mef, establishment: @etab) ||
            FactoryBot.create(:classe, establishment: @etab, label: classe, mef: @mef)
  @student = FactoryBot.create(:student, first_name:, last_name:)
  @student.schoolings.create!(classe: @classe)
end

Sachantque("il y a un(e) élève avec une scolarité fermée qui a une PFMP") do
  @etab ||= User.last.selected_establishment
  classe = @etab.classes.first || FactoryBot.create(:classe, establishment: establishment)
  schooling = FactoryBot.create(:schooling, :closed, classe: classe)
  FactoryBot.create(:pfmp, schooling: schooling)
end

Alors("le fil d'Ariane affiche {string}") do |path|
  components = path.split(" > ")

  breadcrumbs = page.all("nav.fr-breadcrumb li").map(&:text)

  expect(breadcrumbs).to eq components
end

Quand("l'élève n'a réalisé aucune PFMP") do
  @student.current_schooling.pfmps.delete_all
end

Quand("l'élève a une PFMP dans un autre établissement") do
  schooling = FactoryBot.create(:schooling, :closed, student: @student)
  FactoryBot.create(:pfmp, schooling: schooling)
end

Alors("l'élève a {int} PFMP") do |count|
  expect(@student.pfmps.count).to eq count
end

Quand("je renseigne les coordonnées bancaires de l'élève {string} de la classe {string}") do |name, label|
  steps %(
    Quand je consulte la classe "#{label}"
    Et que je clique sur "Voir le profil de #{name}"
    Et que je clique sur "Saisir les coordonnées bancaires"
    Et que je saisis des coordonnées bancaires
    Et que je clique sur "Enregistrer"
  )
end

Quand("l'élève {string} a déjà des coordonnées bancaires") do |name|
  student = find_student_by_full_name(name)
  FactoryBot.create(:rib, student: student)
end

Quand("l'élève {string} a une adresse en France et son propre RIB") do |name|
  student = find_student_by_full_name(name)
  student.update!(address_country_code: "99100")
  student.rib.update!(personal: true)
end

Quand("l'élève {string} a des données correctes pour l'ASP") do |name|
  steps %(
    Quand l'élève "#{name}" a déjà des coordonnées bancaires
    Et que l'élève "#{name}" a une adresse en France et son propre RIB
  )
end

Quand("je clique sur {string} dans le menu principal") do |item|
  within("nav#main-nav") do
    click_link_or_button(item)
  end
end

Quand("je consulte la liste des classes") do
  steps %(Quand je clique sur "Élèves" dans le menu principal)
end

Quand("je consulte le profil de {string} dans la classe de {string}") do |name, label|
  steps %(
    Quand je consulte la classe de "#{label}"
    Et que je clique sur "Voir le profil de #{name}"
  )
end

Quand("je renseigne une PFMP de {int} jours") do |days|
  steps %(
    Quand je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "17/03/2024"
    Et que je remplis "Date de fin" avec "20/03/2024"
    Et que je remplis "Nombre de jours effectués" avec "#{days}"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je renseigne une PFMP de {int} jours pour {string}") do |days, name|
  steps %(
    Et que je clique sur "Voir le profil" dans la rangée "#{name}"
    Et que je renseigne une PFMP de #{days} jours
  )
end

Quand("je renseigne une PFMP pour {string}") do |name|
  steps %(
    Et que je clique sur "Voir le profil" dans la rangée "#{name}"
    Et que je renseigne une PFMP provisoire
  )
end

Quand("je consulte la dernière PFMP") do
  steps %(
    Et que je clique sur "Voir la PFMP" dans la dernière rangée
  )
end

Alors("je ne peux pas éditer ni supprimer la PFMP") do
  steps %(
    Alors la page contient un bouton "Modifier la PFMP" désactivé
    Et la page contient un bouton "Supprimer la PFMP" désactivé
  )
end

Quand("je renseigne et valide une PFMP de {int} jours") do |days|
  steps %(
    Quand je renseigne une PFMP de #{days} jours
    Et que je consulte la dernière PFMP
    Et que je clique sur "Valider"
  )
end

Sachantque(
  "mon établissement propose une formation {string} rémunérée à {int} euros par jour et plafonnée à {int} euros par an"
) do |mef, rate, cap|
  mef = FactoryBot.create(:mef, code: mef, label: mef, short: mef)
  mef.wage.update!(daily_rate: rate, yearly_cap: cap)
end

Quand("je consulte la classe {string}") do |label|
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je consulte la liste des classes
    Et je clique sur "Voir la classe" dans la rangée "#{label}"
  )
end

Quand("je renseigne une PFMP provisoire") do
  steps %(
    Et que je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "17/03/2024"
    Et que je remplis "Date de fin" avec "20/03/2024"
    Et que je clique sur "Enregistrer"
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
    Quand je consulte la classe "#{classe}"
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

Lorsque("je génère les décisions d'attribution de mon établissement") do
  steps %(
    Sachant que je me rends sur la page d'accueil
    Et que toutes les tâches de fond sont terminées
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
  )
end

Sachantque("mon établissement a un directeur confirmé nommé {string}") do |name|
  FactoryBot.create(:user, :confirmed_director, name: name, establishment: Establishment.last)
end
