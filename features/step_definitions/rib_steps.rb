# frozen_string_literal: true

Lorsque("je renseigne des coordonnées bancaires") do
  steps %(
    Quand je remplis les informations bancaires de "#{@student.full_name}"
    Et que je choisis "Les coordonnées bancaires appartiennent à l'élève"
    Et que je clique sur "Enregistrer"
  )
end

Quand("je remplis les informations bancaires de {string}") do |name|
  rib = FactoryBot.build(:rib)

  steps %(
    Quand je remplis "Titulaire du compte" avec "#{name}"
    Et que je remplis "IBAN" avec "#{rib.iban}"
    Et que je remplis "BIC" avec "#{rib.bic}"
  )
end

Quand("je saisis les coordonées bancaires d'un tiers pour {string}") do |name|
  steps %(
    Quand je remplis les informations bancaires de "#{name}"
    Et que je décoche "Les coordonnées bancaires appartiennent à l'élève"
  )
end

Quand("je saisis en masse les coordonées bancaires d'un tiers pour {string}") do |name|
  within_fieldset(name) do
    steps %(
      Quand je remplis les informations bancaires de "#{name}"
      Et que je décoche "Les coordonnées bancaires appartiennent à l'élève"
    )
  end
end
