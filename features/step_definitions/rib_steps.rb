# frozen_string_literal: true

# FIXME: avoid stateful steps
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

Quand("je saisis des coordonnées bancaires") do
  rib = FactoryBot.build(:rib)

  steps %(
    Quand je remplis "Titulaire du compte" avec "#{rib.name}"
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

Quand("je supprime les coordonnées bancaires") do
  steps %(
    Quand je clique sur "Supprimer les coordonnées bancaires"
    Et que je clique sur "Confirmer la suppression"
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

Quand("le panel de saisie de coordonnées bancaires de {string} contient {string}") do |name, content|
  within_fieldset(name) do
    expect(page).to have_content(content)
  end
end

Quand("je renseigne les coordonnées bancaires de l'élève {string} de la classe {string}") do |name, label|
  steps %(
    Quand je consulte la classe "#{label}"
    Et que je clique sur "Voir le profil de #{name}"
    Et que je clique sur "Saisir les coordonnées bancaires"
    Et que je saisis des coordonnées bancaires
    Et que je clique sur "Enregistrer"
  )
end

Quand("l'élève {string} a déjà des coordonnées bancaires") do |name|
  student = find_student_by_full_name(name)
  FactoryBot.create(:rib, student: student)
end
