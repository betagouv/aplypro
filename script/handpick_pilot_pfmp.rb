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


# "1089694, 1089640, 972220, 1019171, 1019174, 1019175, 1019179, 1019182, 1019186, 1019189, 1019181, 1093659, 1093672, 616421, 809543, 809567, 548071, 809519, 548075, 548081, 548079, 548102, 809470, 985713, 809668, 89077, 89076, 89078, 1086783, 1086789, 1034895, 1094073, 1093714, 1097050, 1097555, 1097559, 1097604, 1093642, 1086792, 549944, 549945, 549943, 548078, 549899, 549904, 549905, 549907, 549908, 549909, 809667, 809530, 809457, 809577, 339012, 993999, 963278, 963440, 963062, 963467, 962888, 962920, 962921, 962903, 963008, 962998, 962821, 962923, 963380, 962980, 962919, 962916, 1093634, 614523, 614518, 614519, 614520, 614521, 614522, 614524, 320623, 698214, 698215, 698216, 822847, 822852, 823217, 823307, 823308, 823309, 823314, 823315, 823316, 823318, 823320, 823321, 823322, 823323, 823324, 823325, 823327, 823328, 823331, 823333, 823334, 823162, 823250, 720913, 787283, 787278, 787284, 787277, 787282, 787281, 992117, 992115, 992111, 992109, 720911, 737933, 737934, 737935, 737938, 737939, 737940, 737941, 295052, 295050, 809648, 792892, 792893, 792894, 792895, 792898, 792900, 792901, 792902, 792903, 792904, 792905, 792906, 792907, 792908, 792909, 720912, 757242, 757252, 757254, 757257, 757260, 757264, 757272, 757275, 757289, 757246, 757249, 757304, 757262, 757277, 757301, 757302, 787286, 827218, 827073, 320642, 720910, 704308, 704309, 704313, 704316, 704317, 799794, 799780, 704311, 704318, 817651, 817653, 817655, 817658, 720921, 435197, 435587, 435588, 435589, 435592, 435594, 435595, 435596, 435599, 435600, 435601, 435593, 435590, 435602, 435598"


# ........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................."Update payment amount of pfmp #720913 from 560.0 to 360"
# ..........................................................................................................................."Update payment amount of pfmp #720910 from 560.0 to 360"
# ........................"Update payment amount of pfmp #704311 from 195.0 to 480"
# ."Update payment amount of pfmp #704318 from 195.0 to 480"
# ........................................."Update payment amount of pfmp #720921 from 1120.0 to 360"
# ..................................................................................