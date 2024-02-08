# frozen_string_literal: true

World(ActionView::Helpers::NumberHelper)

Quand("la tâche de préparation des paiements démarre") do
  PreparePaymentsJob.perform_later
end

Quand("la tâche d'envoi des paiements démarre") do
  SendPaymentsJob.perform_later(Payment.all.map(&:id))
end

Sachantqu("la tâche de lecture des paiements démarre") do
  PollPaymentsServerJob.perform_later
end

Sachantqu("il n'y a pas de fichiers sur le serveur de l'ASP") do
  FileUtils.rm_rf(TEMP_ASP_DIR) && FileUtils.mkdir_p(TEMP_ASP_DIR)
end

Quand("l'ASP a mis a disposition un fichier {string} contenant :") do |filename, string|
  destination = File.join("tmp/mock_asp", filename)

  File.write(destination, string, encoding: "ISO8859-1")
end

Sachantque("l'ASP a rejetté le dossier de {string} avec un motif de {string} dans un fichier {string}") do |name, reason, filename|
  first_name, last_name = name.split
  student = Student.find_by(first_name:, last_name:)

  steps %(
    Sachant que l'ASP a mis a disposition un fichier "#{filename}" contenant :
      """
      Numéro d'enregistrement;Type d'entité;Numadm;Motif rejet;idIndDoublon
      #{student.id};;;#{reason};
      """
  )
end

Sachantque("l'ASP a accepté le dossier de {string} dans un fichier {string}") do |name, filename|
  first_name, last_name = name.split
  student = Student.find_by(first_name:, last_name:)

  steps %(
    Sachant que l'ASP a mis a disposition un fichier "#{filename}" contenant :
      """
      Numero enregistrement;idIndDoss;idIndTiers;idDoss;numAdmDoss;idPretaDoss;numAdmPrestaDoss;idIndPrestaDoss
      #{student.id};700056261;;700086362;ENPUPLF1POP31X20230;700085962;ENPUPLF1POP31X20230;700056261
      """
  )
end

Sachantque("le dernier paiement de {string} a été envoyé avec un fichier {string}") do |name, filename|
  first_name, last_name = name.split

  payment = Student
            .find_by(first_name:, last_name:)
            .payments
            .in_state(:processing)
            .last

  payment.asp_request.file.update!(filename: filename)
end

Alors("je peux voir un paiement {string} de {int} euros") do |state, amount|
  steps %(
    Alors la page contient "#{state}"
    Et la page contient "#{number_to_currency(amount)}"
  )
end
