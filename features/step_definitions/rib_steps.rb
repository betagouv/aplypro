# frozen_string_literal: true

Quand("je remplis des coordonnées bancaires") do
  rib = FactoryBot.build(:rib)

  steps %(
    Quand je remplis "Titulaire du compte" avec "#{name}"
    Et que je remplis "IBAN" avec "#{rib.iban}"
    Et que je remplis "BIC" avec "#{rib.bic}"
  )
end

Quand("je saisis les coordonnées bancaires de l'élève") do
  steps %(
    Quand je remplis des coordonnées bancaires
    Et que je choisis "Les coordonnées bancaires appartiennent à l'élève"
  )
end

Quand("je saisis les coordonnées bancaires d'un tiers") do
  steps %(
    Quand je remplis des coordonnées bancaires
    Et que je choisis "Les coordonnées bancaires appartiennent à un représentant légal ou à un tiers"
  )
end

Quand("je supprime les coordonnées bancaires") do
  steps %(
    Quand je clique sur "Supprimer les coordonnées bancaires"
    Et que je clique sur "Confirmer la suppression"
  )
end

Quand("je saisis en masse les coordonnées bancaires d'un tiers pour {string}") do |name|
  within_fieldset(name) do
    steps %(
      Quand je remplis des coordonnées bancaires
      Et que je choisis "Un représentant légal ou à un tiers"
    )
  end
end

Quand("je saisis en masse les coordonnées bancaires d'une personne morale pour {string}") do |name|
  within_fieldset(name) do
    steps %(
      Quand je remplis des coordonnées bancaires
      Et que je choisis "Une personne morale"
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
    Quand je consulte le profil de "#{name}" dans la classe de "#{label}"
    Et que je clique sur "Saisir les coordonnées bancaires"
    Et que je saisis les coordonnées bancaires de l'élève
    Et que je clique sur "Enregistrer"
  )
end

Quand("l'élève {string} a déjà des coordonnées bancaires") do |name|
  student = find_student_by_full_name(name)
  FactoryBot.create(:rib, :personal, student: student)
end

Quand("l'élève {string} a déjà des coordonnées bancaires pour l'établissement {string}") do |name, uai|
  student = find_student_by_full_name(name)
  etab = Establishment.find_by!(uai: uai)
  FactoryBot.create(:rib, :personal, student: student, establishment: etab)
end

Quand("il manque des coordonnées bancaires à {string}") do |name|
  student = find_student_by_full_name(name)

  student.ribs.destroy_all
end
