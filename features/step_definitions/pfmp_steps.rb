# frozen_string_literal: true

Quand("je renseigne une PFMP de {int} jours") do |days|
  start_date = Date.parse("#{SchoolYear.current.end_year}-03-17")
  end_date   = start_date + days.days

  steps %(
    Quand je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "#{start_date}"
    Et que je remplis "Date de fin" avec "#{end_date}"
    Et que je remplis "Nombre de jours effectués" avec "#{days}"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je renseigne une PFMP de {int} jours pour la classe {string}") do |days, classe|
  start_date = Date.parse("#{SchoolYear.current.end_year}-03-17")
  end_date   = start_date + days.days

  steps %(
    Quand je clique sur "Ajouter une PFMP" dans la classe "#{classe}"
    Et que je remplis "Date de début" avec "#{start_date}"
    Et que je remplis "Date de fin" avec "#{end_date}"
    Et que je remplis "Nombre de jours effectués" avec "#{days}"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je renseigne une PFMP de {int} jours pour {string}") do |days, name|
  steps %(
    Et que je clique sur "Voir le profil de #{name}"
    Et que je renseigne une PFMP de #{days} jours
  )
end

Quand("je renseigne une PFMP pour {string}") do |name|
  steps %(
    Et que je clique sur "Voir le profil de #{name}"
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

Quand("je renseigne et valide une PFMP de {int} jours pour {string}") do |days, name|
  steps %(
    Quand je renseigne une PFMP de #{days} jours pour "#{name}"
    Et que la dernière PFMP de "#{name}" est validable
    Et que je consulte la dernière PFMP
    Et que je coche la case de responsable légal
    Et que je clique sur "Valider"
  )
end

Quand("je renseigne une PFMP provisoire") do
  start_date = Date.parse("#{SchoolYear.current.end_year}-03-17")
  end_date = start_date + 3.days

  steps %(
    Et que je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "#{start_date}"
    Et que je remplis "Date de fin" avec "#{end_date}"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je renseigne une PFMP provisoire dans la période de report pour l'élève {string}") do |name|
  schooling = find_schooling_by_student_full_name(name)
  start_date = schooling.end_date - 3.days
  end_date = schooling.end_date + 3.days

  steps %(
    Et que je clique sur "Ajouter une PFMP"
    Et que je remplis "Date de début" avec "#{start_date}"
    Et que je remplis "Date de fin" avec "#{end_date}"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je renseigne {int} jours pour la dernière PFMP de {string} dans la classe de {string}") do |days, name, classe|
  new_end_date = Date.parse("#{SchoolYear.current.end_year}-03-17") + days.days

  steps %(
    Quand je consulte le profil de "#{name}" dans la classe de "#{classe}"
    Et que je consulte la dernière PFMP
    Et que je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "#{days}"
    Et que je remplis "Date de fin" avec "#{new_end_date}"
    Et que je clique sur "Modifier la PFMP"
    Alors la page contient "La PFMP a bien été mise à jour"
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

Quand("la dernière PFMP de {string} est validable") do |name|
  student = find_student_by_full_name(name)

  steps %(
    Et que l'élève "#{name}" a déjà des coordonnées bancaires
  ) if student.ribs.empty?

  pfmp = student.pfmps.last
  schooling = pfmp.schooling

  schooling.tap(&:generate_administrative_number).save!
  schooling.attach_attributive_document(StringIO.new("hello"), :attributive_decision)
end

Alors("je peux changer le nombre de jours de la PFMP à {int}") do |days|
  steps %(
    Quand je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "#{days}"
    Et que je clique sur "Modifier la PFMP"
    Alors la page contient "La PFMP a bien été mise à jour"
  )
end
