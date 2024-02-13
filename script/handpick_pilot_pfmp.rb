# establishment = Establishment.find_by(uai: "0951787B")
# Aucun étudiant ASP ready dans cet établissement.

# Cette range sert à sélectionner les premières PFMPs tout en évitant de
# sélectionner des erreurs de saisies dont la date est avant septembre 2023
early_range = Date.parse("2023-09-01")..Date.parse("2023-10-31")

pfmps = Pfmp.joins(:establishment)
  .where("establishments.students_provider": :sygne)
  .in_state(:validated)
  .where(start_date: early_range)
  .order(start_date: :asc)
  .limit(1000)

students_data = {}
selected_pfmps = []

pfmps.each do |pfmp|
  print "."
  # Check les data requises pour ASP
  next unless ASP::StudentFileEligibilityChecker.new(pfmp.student).ready?

  # Check que la DA a été générée
  next if pfmp.schooling.attributive_decision.blank?

  # Check si c'est bien un non-apprenti
  students_data[pfmp.student.id] ||= StudentApi.fetch_student_data!(:sygne, establishment.uai, pfmp.student.ine)
  student_data = students_data[pfmp.student.id]
  apprentice_statut = student_data["scolarite"]["codeStatut"]

  next if apprentice_statut == "AP"

  # Pas besoin de checker le hors contrat pour le pilote Versailles
  # ---- #

  # Check que la pfmp a bien une date de fin dans le passé (est terminée)
  next if pfmp.end_date > Date.today

  # Check que l'élève n'est pas devenu majeur alors qu'il a un RIB de tiers
  next if pfmp.student.birthdate <= 18.years.ago && !pfmp.student.rib.personal

  # Check que l'élève n'a pas eu une autre formation avant
  other_schoolings = pfmp.student.schoolings.where.not(id: pfmp.schooling_id).where.not(start_date: nil).order(start_date: :asc)
  next if other_schoolings.any? && other_schoolings.first.start_date < pfmp.schooling.start_date

  # Check que l'élève a son adresse en france
  next unless %w[99100 100].include? pfmp.student.address_country_code

  # Supprime tous les extra payments rattachés à la pfmp
  payment, *extra_payments = pfmp.payments
  extra_payments.each(&:destroy)

  # Check que le montant du paiement est correct, et l'update si non
  # Ce code ne fonctionne que pour le paiment d'une pfmp unique
  expected_amount = [pfmp.mef.wage.daily_rate * pfmp.day_count, pfmp.mef.wage.yearly_cap].min

  if payment.amount != expected_amount
    print "Update payment amount of pfmp ##{pfmp.id} from #{payment.amount} to #{expected_amount}"
    payment.update(amount: expected_amount)
  end

  selected_pfmps.push pfmp
end; nil

# selected_pfmps

selected_uai_counts = selected_pfmps.group_by { |pfmp| pfmp.establishment.uai }.transform_values(&:count)

data = Establishment.where(uai: selected_uai_counts.keys).to_a.map do |etab|
  [etab.uai, etab.name, etab.ministry, etab.academy_label, etab.private_contract_type_code, selected_uai_counts[etab.uai], pfmps.where("establishments.id": etab.id).count].join(";")
end

puts data
