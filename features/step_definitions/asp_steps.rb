# frozen_string_literal: true

Quand("je me rend sur la page de recherche de dossier") do
  visit "/asp/schoolings"
end

# rubocop:disable Layout/LineLength
Quand("une PFMP de 30 euros a été saisie, validée et envoyée en paiement pour l'élève {string}") do |name|
  steps %(
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "#{name}" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Et que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours pour "#{name}"
    Et que la dernière PFMP de "#{name}" en classe de "A1" a une requête de paiement envoyée
  )
end
# rubocop:enable Layout/LineLength

Sachantque("le numéro administratif de {string} est {string}") do |name, administrative_number|
  student = find_student_by_full_name(name)
  schooling = student.current_schooling
  schooling.update!(administrative_number: administrative_number)
  schooling.attributive_decision.update!(
    filename: ASP::AttachDocument.attachment_file_name(schooling, "décision-d-attribution")
  )
end

Sachantque("le numéro de dossier ASP de {string} est {string}") do |name, dossier_id|
  student = find_student_by_full_name(name)
  schooling = student.current_schooling
  schooling.update!(asp_dossier_id: dossier_id)
end

Sachantque("le numéro de prestation dossier ASP de la PFMP de {string} est {string}") do |name, prestation_dossier_id|
  student = find_student_by_full_name(name)
  schooling = student.current_schooling
  schooling.pfmps.first.update!(asp_prestation_dossier_id: prestation_dossier_id)
end
