# frozen_string_literal: true

Quand("l'élève {string} a quitté l'établissement {string}") do |name, uai|
  student = find_student_by_full_name(name)

  steps %(
    Sachant que l'API SYGNE renvoie un élève avec l'INE "#{student.ine}" qui a quitté l'établissement "#{uai}"
    Et que la liste des élèves de l'établissement "#{uai}" est rafraîchie
    Et que toutes les tâches de fond sont terminées
    )
end

Sachantque("les informations personnelles ont été récupérées pour l'élève {string}") do |name|
  student = find_student_by_full_name(name)

  Sync::StudentJob.perform_now(student.current_schooling)
end

Sachantque("les informations personnelles ont été récupérées pour tous les élèves de l'établissement {string}") do |uai|
  establishment = Establishment.find_by(uai: uai)

  ActiveJob.perform_all_later(establishment.schoolings.map { |schooling| Sync::StudentJob.new(schooling) })
end

Quand(
  "l'élève {string} a une ancienne scolarité dans la classe {string} dans le même établissement"
) do |name, classe_label|
  establishment = Establishment.last
  student = find_student_by_full_name(name)
  classe = Classe.find_by(label: classe_label, establishment: establishment) ||
           FactoryBot.create(:classe, label: classe_label, establishment: establishment)

  FactoryBot.create(:schooling, :closed, student: student, classe: classe)
end

Quand("l'élève {string} {string} a une ancienne scolarité dans un autre établissement") do |first_name, last_name|
  student = Student.find_by(first_name: first_name, last_name: last_name)
  other_classe = FactoryBot.create(:classe)
  FactoryBot.create(:schooling, :closed, student: student, classe: other_classe)
end

# rubocop:disable Layout/LineLength
Quand("l'élève {string} a une ancienne scolarité dans la classe {string} dans un autre établissement") do |name, classe_label|
  student = find_student_by_full_name(name)
  classe = Classe.find_by(label: classe_label) || FactoryBot.create(:classe, label: classe_label)

  FactoryBot.create(:schooling, :closed, student: student, classe: classe)
end
# rubocop:enable Layout/LineLength

Quand("les élèves actuels sont les seuls à avoir des décisions d'attribution") do
  establishment = Establishment.last

  establishment.schoolings.current.find_each do |schooling|
    schooling.attach_attributive_document(StringIO.new("hello"), :attributive_decision)
  end
end

Quand("les élèves ont un report de décisions d'attribution") do
  establishment = Establishment.last

  establishment.schoolings.find_each do |schooling|
    schooling.update!(extended_end_date: "2024-11-02")
  end
end

# FIXME: we should mock the API step instead and have the correct
# schooling + status returned in the data.
Quand("l'élève {string} a bien le statut étudiant") do |name|
  student = find_student_by_full_name(name)

  student.current_schooling.update!(status: :student)
end

Sachantque("l'élève {string} n'a pas d'INE") do |name|
  student = find_student_by_full_name(name)
  student.update!(ine_not_found: true)
end

Sachantque("l'élève {string} a un INE") do |name|
  student = find_student_by_full_name(name)
  student.update!(ine_not_found: false)
end
