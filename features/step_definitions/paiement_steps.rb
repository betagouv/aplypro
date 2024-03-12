# frozen_string_literal: true

World(ActionView::Helpers::NumberHelper)

Quand("la tâche de préparation des paiements démarre") do
  PreparePaymentRequestsJob.perform_later
end

Quand("la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi") do
  SendPaymentRequestsJob.perform_later(ASP::PaymentRequest.in_state(:ready).to_a)
end

Quand("les tâches de préparation et d'envoi des paiements sont passées") do
  steps %(
    Quand la tâche de préparation des paiements démarre
    Et que toutes les tâches de fond sont terminées
    Et que la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi
    Et que toutes les tâches de fond sont terminées
  )
end

Sachantqu("la tâche de lecture des paiements démarre") do
  PollPaymentsServerJob.perform_later
end

Sachantqu("il n'y a pas de fichiers sur le serveur de l'ASP") do
  FileUtils.rm_rf(TEMP_ASP_DIR) && FileUtils.mkdir_p(TEMP_ASP_DIR)
end

Quand("l'ASP a mis a disposition un fichier {string} contenant :") do |filename, string|
  destination = File.join("tmp/mock_asp", filename)

  File.write(destination, string)
end

Sachantque(
  "l'ASP a rejetté le dossier de {string} avec un motif de {string} dans un fichier {string}"
) do |name, reason, filename|
  first_name, last_name = name.split
  student = Student.find_by(first_name:, last_name:)

  request = student.pfmps.last.payment_requests.last

  steps %(
    Sachant que l'ASP a mis a disposition un fichier "#{filename}" contenant :
      """
      Numéro d'enregistrement;Type d'entité;Numadm;Motif rejet;idIndDoublon
      #{request.id};;;#{reason};
      """
  )
end

Sachantque("l'ASP a accepté le dossier de {string} dans un fichier {string}") do |name, filename|
  first_name, last_name = name.split
  student = Student.find_by(first_name:, last_name:)

  request = student.pfmps.last.payment_requests.last

  steps %(
    Sachant que l'ASP a mis a disposition un fichier "#{filename}" contenant :
      """
      Numero enregistrement;idIndDoss;idIndTiers;idDoss;numAdmDoss;idPretaDoss;numAdmPrestaDoss;idIndPrestaDoss
      #{request.id};700056261;;700086362;ENPUPLF1POP31X20230;700085962;ENPUPLF1POP31X20230;700056261
      """
  )
end

Sachantque("le dernier paiement de {string} a été envoyé avec un fichier {string}") do |name, filename|
  first_name, last_name = name.split

  pfmp = Student
         .find_by(first_name:, last_name:)
         .pfmps
         .last

  pfmp.payment_requests.last.asp_request.file.update!(filename: filename)
end

Alors("je peux voir une demande de paiement {string}") do |state|
  expect(page).to have_css(".fr-badge:not(.disabled)", text: state)
end

Alors("je peux voir une demande de paiement {string} de {int} euros") do |state, amount|
  steps %(
    Alors je peux voir une demande de paiement "#{state}"
    Et la page contient "#{number_to_currency(amount)}"
  )
end
