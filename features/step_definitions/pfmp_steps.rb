# frozen_string_literal: true

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

Quand("je valide la dernière PFMP de {string}") do |name|
  student = find_student_by_full_name(name)

  student.pfmps.last.transition_to!(:validated)
end
