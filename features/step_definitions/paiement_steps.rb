# frozen_string_literal: true

World(ActionView::Helpers::NumberHelper)

# hack
def last_payment_request_for_name(name)
  find_student_by_full_name(name)
    .pfmps
    .last
    .payment_requests
    .last
end

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

Sachantque("l'ASP a rejetté le dossier de {string} avec un motif de {string}") do |name, reason|
  request = last_payment_request_for_name(name)

  FactoryBot.create(
    :asp_reject,
    payment_request: request,
    reason: reason,
    destination: TEMP_ASP_DIR
  )
end

Sachantque("l'ASP a accepté le dossier de {string}") do |name|
  request = last_payment_request_for_name(name)

  FactoryBot.create(
    :asp_integration,
    payment_request: request,
    destination: TEMP_ASP_DIR
  )
end

Sachantque("l'ASP a liquidé le paiement de {string}") do |name|
  request = last_payment_request_for_name(name)

  FactoryBot.create(
    :asp_payment_return,
    :success,
    builder_class: ASP::Builder,
    payment_request: request,
    destination: TEMP_ASP_DIR
  )
end

Sachantque("l'ASP n'a pas pu liquider le paiement de {string}") do |name|
  request = last_payment_request_for_name(name)

  FactoryBot.create(
    :asp_payment_return,
    :failed,
    builder_class: ASP::Builder,
    payment_request: request,
    destination: TEMP_ASP_DIR
  )
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
