# frozen_string_literal: true

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

Sachantque("l'élève {string} a une scolarité fermée") do |name|
  student = find_student_by_full_name(name)

  student.current_schooling.update!(end_date: Date.yesterday)
end

Quand("l'élève {string} a une PFMP dans un autre établissement") do |name|
  student = find_student_by_full_name(name)

  schooling = FactoryBot.create(:schooling, :closed, student: student)

  FactoryBot.create(:pfmp, schooling: schooling)
end

Alors("l'élève a {int} PFMP") do |count|
  expect(@student.pfmps.count).to eq count
end

Quand("je consulte la liste des classes") do
  steps %(Quand je clique sur "Élèves" dans le menu principal)
end

Quand("je consulte le profil de {string} dans la classe de {string}") do |name, label|
  steps %(
    Quand je consulte la liste des classes
    Et que je consulte la classe de "#{label}"
    Et que je clique sur "Voir le profil de #{name}"
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

Alors("il y a un compte utilisateur enregistré") do
  expect(User.count).to eq 1
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
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
  )
end

Sachantque("mon établissement a un directeur confirmé nommé {string}") do |name|
  FactoryBot.create(:user, :confirmed_director, name: name, establishment: Establishment.last)
end

Sachantque(
  "j'ai une classe {string} de {int} élèves " \
  "pour l'établissement {string} lors de l'année {int}"
) do |classe, count, uai, start_year|
  establishment = Establishment.find_by!(uai: uai)
  school_year = SchoolYear.find_by!(start_year: start_year)

  FactoryBot.create(
    :classe,
    :with_students,
    students_count: count,
    label: classe,
    school_year: school_year,
    establishment: establishment
  )
end
