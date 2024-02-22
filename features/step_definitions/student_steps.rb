# frozen_string_literal: true

Quand("l'élève de SYGNE avec l'INE {string} a quitté l'établissement {string}") do |ine, uai|
  steps %(
    Sachant que l'API SYGNE renvoie un élève avec l'INE "#{ine}" qui a quitté l'établissement "#{uai}"
    Et que la liste des élèves de l'établissement "#{uai}" est rafraîchie
    Et que toutes les tâches de fond sont terminées
    )
end

Sachantque("les informations personnelles ont été récupérées pour l'élève avec l'INE {string}") do |ine|
  student = Student.find_by(ine: ine)

  FetchStudentInformationJob.perform_now(student.current_schooling)
end

Quand("l'élève avec l'INE {string} s'appelle {string} {string}") do |ine, first_name, last_name|
  Student.find_by(ine:).update(first_name:, last_name:)
end

Quand(
  "l'élève avec l'INE {string} a une ancienne scolarité dans la classe {string} dans le même établissement"
) do |ine, classe_label|
  establishment = Establishment.last
  student = Student.find_by(ine: ine)
  classe = Classe.find_by(label: classe_label, establishment: establishment) ||
           FactoryBot.create(:classe, label: classe_label, establishment: establishment)

  FactoryBot.create(:schooling, student: student, classe: classe, end_date: Date.yesterday)
end

Quand("l'élève {string} {string} a une ancienne scolarité dans un autre établissement") do |first_name, last_name|
  student = Student.find_by(first_name: first_name, last_name: last_name)
  other_classe = FactoryBot.create(:classe)
  FactoryBot.create(:schooling, student: student, classe: other_classe, end_date: Date.yesterday)
end

Quand("les élèves actuels sont les seuls à avoir des décisions d'attribution") do
  establishment = Establishment.last

  establishment.schoolings.current.find_each do |schooling|
    schooling.rattach_attributive_decision!(StringIO.new("hello"))
  end
end
