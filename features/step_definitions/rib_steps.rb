# frozen_string_literal: true

Lorsque("je renseigne des coordonnées bancaires") do
  rib = FactoryBot.build(:rib, student: @student)

  steps %(
    Et que je remplis "Titulaire du compte" avec "#{rib.student.full_name}"
    Et que je remplis "IBAN" avec "#{rib.iban}"
    Et que je remplis "BIC" avec "#{rib.bic}"
    Et que je choisis "Les coordonnées bancaires appartiennent à l'élève"
    Et que je clique sur "Enregistrer"
  )
end
