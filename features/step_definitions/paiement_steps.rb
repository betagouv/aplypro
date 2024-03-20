# frozen_string_literal: true

World(ActionView::Helpers::NumberHelper)

Quand("la tâche de préparation des paiements démarre") do
  PreparePaymentRequestsJob.perform_later
end

Quand("la tâche de préparation des paiements est passée") do
  steps %(
    Quand la tâche de préparation des paiements démarre
    Et que toutes les tâches de fond sont terminées
  )
end

Quand("la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi") do
  SendPaymentRequestsJob.perform_later(ASP::PaymentRequest.in_state(:ready).to_a)
end

Quand("les tâches de préparation et d'envoi des paiements sont passées") do
  steps %(
    Quand la tâche de préparation des paiements est passée
    Et que la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi
    Et que toutes les tâches de fond sont terminées
  )
end

Sachantqu("la tâche de lecture des paiements démarre") do
  PollPaymentsServerJob.perform_later
end

Sachantqu("la tâche de lecture des paiements est passée") do
  steps %(
    Quand la tâche de lecture des paiements démarre
    Et que toutes les tâches de fond sont terminées
  )
end

Sachantqu("il n'y a pas de fichiers sur le serveur de l'ASP") do
  FileUtils.rm_rf(TEMP_ASP_DIR) && FileUtils.mkdir_p(TEMP_ASP_DIR)
end

Quand("l'ASP a mis a disposition un fichier {string} contenant :") do |filename, string|
  destination = File.join("tmp/mock_asp", filename)

  File.write(destination, string)
end

# rubocop:disable Metrics/AbcSize
def asp_answers_for_dossier(name, is_successful, reason="")
  first_name, last_name = name.split
  student = Student.find_by(first_name:, last_name:)

  file_name_type = is_successful ? :integrations : :rejects
  file_type = is_successful ? :asp_integration : :asp_reject

  request = student.pfmps.last.payment_requests.last
  identifier = request.asp_request.file.filename.to_s.split(".xml").first
  file_name = FactoryBot.build(:asp_filename, file_name_type, identifier: identifier)
  file_content = FactoryBot.build(file_type, payment_request: request, reason: reason)

  steps %(
    Sachant que l'ASP a mis a disposition un fichier "#{file_name}" contenant :
      """
      #{file_content}
      """
  )
end
# rubocop:enable Metrics/AbcSize

Sachantque("l'ASP a rejetté le dossier de {string} avec un motif de {string}") do |name, reason|
  asp_answers_for_dossier(name, false, reason)
end

Sachantque("l'ASP a accepté le dossier de {string}") do |name|
  asp_answers_for_dossier(name, true)
end

def asp_answers_for_payment(name, is_successful)
  first_name, last_name = name.split
  student = Student.find_by(first_name:, last_name:)
  request = student.pfmps.last.payment_requests.last
  state = is_successful ? :success : :failed

  payment_return_file = FactoryBot.build(
    :asp_payment_return,
    state,
    builder_class: ASP::Builder,
    payment_request: request
  )

  filename = FactoryBot.build(:asp_filename, :payments)

  steps %(
    Sachant que l'ASP a mis a disposition un fichier "#{filename}" contenant :
      """
      #{payment_return_file}
      """
  )
end

Sachantque("l'ASP a liquidé le paiement de {string}") do |name|
  asp_answers_for_payment(name, true)
end

Sachantque("l'ASP n'a pas pu liquider le paiement de {string}") do |name|
  asp_answers_for_payment(name, false)
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
