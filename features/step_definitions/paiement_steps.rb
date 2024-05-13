# frozen_string_literal: true

World(ActionView::Helpers::NumberHelper)

Quand("la tâche de préparation des paiements démarre") do
  ConsiderPaymentRequestsJob.perform_later(1.year.from_now)
end

Quand("la tâche de préparation des paiements est passée") do
  steps %(
    Quand la tâche de préparation des paiements démarre
    Et que toutes les tâches de fond et leurs sous-tâches sont terminées
  )
end

Quand("la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi") do
  requests = ASP::PaymentRequest.in_state(:ready)

  SendPaymentRequestsJob.perform_later if requests.any?
end

Quand("la tâche d'envoi des paiements est passée") do
  steps %(
    Quand la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi
    Et que toutes les tâches de fond sont terminées
  )
end

Quand("les tâches de préparation et d'envoi des paiements sont passées") do
  steps %(
    Quand la tâche de préparation des paiements est passée
    Et la tâche d'envoi des paiements est passée
  )
end

Sachantqu("la tâche de lecture des paiements démarre") do
  PollPaymentsServerJob.perform_later
end

Sachantqu("la tâche de lecture des paiements est passée") do
  steps %(
    Quand la tâche de lecture des paiements démarre
    Et que toutes les tâches de fond et leurs sous-tâches sont terminées
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
    :asp_payment_file,
    :success,
    builder_class: ASP::Builder,
    payment_request: request,
    destination: TEMP_ASP_DIR
  )
end

Sachantque("l'ASP n'a pas pu liquider le paiement de {string}") do |name|
  request = last_payment_request_for_name(name)

  FactoryBot.create(
    :asp_payment_file,
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
