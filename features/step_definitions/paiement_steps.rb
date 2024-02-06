# frozen_string_literal: true

World(ActionView::Helpers::NumberHelper)

Quand("la tâche de préparation des paiements démarre") do
  PreparePaymentsJob.perform_later
end

Quand("la tâche d'envoi des paiements démarre") do
  SendPaymentsJob.perform_later(Payment.all.map(&:id))
end

Alors("je peux voir un paiement {string} de {int} euros") do |state, amount|
  steps %(
    Alors la page contient "#{state}"
    Et la page contient "#{number_to_currency(amount)}"
  )
end
