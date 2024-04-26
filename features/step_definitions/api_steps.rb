# frozen_string_literal: true

# NOTE: l'API SYGNE est stateful : parce qu'un élève manquant est un
# élève déscolarisé, il nous faut renvoyer les élèves précédents sous
# peine de les voir disparaître, d'où @sygne_results.

Sachantque(
  "l'API SYGNE renvoie {int} élèves en {string} pour l'établissement {string}"
) do |count, classe, uai|
  mock_sygne_token
  mock_sygne_students_endpoint(uai, FactoryBot.build_list(:sygne_student, count, classe: classe))
end

Sachantque(
  "l'API SYGNE renvoie {int} élèves dans une classe {string} dont {string} pour l'établissement {string}"
) do |count, classe, name, uai|
  mock_sygne_token

  @sygne_results = []

  first_name, last_name = name.split

  payload = FactoryBot.build_list(:sygne_student, count, classe: classe).tap do |students|
    students.last["prenom"] = first_name
    students.last["nom"] = last_name
  end

  @sygne_results << payload

  mock_sygne_students_endpoint(uai, payload)
end

Sachantque(
  "l'API SYGNE renvoie une classe {string} " \
  "de {int} élèves en formation {string} " \
  "dont {string} pour l'établissement {string}"
) do |classe, count, mef, name, uai|
  mock_sygne_token

  @sygne_results = []

  first_name, last_name = name.split

  mef = Mef.find_by!(label: mef)

  payload = FactoryBot.build_list(
    :sygne_student,
    count,
    classe: classe,
    mef_value: mef.code.concat("0")
  ).tap do |students|
    students.last["prenom"] = first_name
    students.last["nom"] = last_name
  end

  @sygne_results << payload

  mock_sygne_students_endpoint(uai, payload)
end

# ce step permet de mocker l'API SYGNE sans inclure la logique des
# autres steps qui construisent les données passées en paramètre.
Sachantque("l'API SYGNE peut renvoyer des élèves pour l'établissement {string}") do |uai|
  mock_sygne_token
  mock_sygne_students_endpoint(uai, [])
end

Sachantque("l'API FREGATA renvoie une liste d'élèves pour l'établissement {string}") do |uai|
  mock_sygne_token
  mock_fregata_students_with(uai, FactoryBot.build_list(:fregata_student, 10))
end

Sachantque("l'API SYGNE renvoie une liste d'élèves pour l'établissement {string}") do |uai|
  mock_sygne_token
  mock_sygne_students_endpoint(uai, FactoryBot.build_list(:sygne_student, 10))
end

Sachantque("l'API SYGNE renvoie une adresse en France pour l'élève {string}") do |name|
  student = find_student_by_full_name(name)

  mock_sygne_student_endpoint_with(student.ine, FactoryBot.build(:sygne_student_info, :french_address).to_json)
end

Sachantque("l'API SYGNE renvoie une adresse à l'étranger pour l'élève {string}") do |name|
  student = find_student_by_full_name(name)

  mock_sygne_student_endpoint_with(student.ine, FactoryBot.build(:sygne_student_info, :foreign_address).to_json)
end

Sachantque("l'API SYGNE peut fournir les informations complètes des étudiants") do
  mock_sygne_token
  mock_sygne_student_endpoint_with("", FactoryBot.build(:sygne_student_info).to_json)
end

Sachantque("les élèves de l'établissement {string} sont rafraîchis") do |uai|
  FetchStudentsJob.new(Establishment.find_by(uai: uai)).perform_now
end

Sachantque("l'API SYGNE renvoie un élève avec l'INE {string} qui a quitté l'établissement {string}") do |ine, uai|
  payload_without_student = @sygne_results.last.dup.reject { |student| student["ine"] == ine }

  mock_sygne_token
  mock_sygne_students_endpoint(uai, payload_without_student)
end

Sachantque("l'API SYGNE renvoie {int} nouvel/nouveaux élève(s) pour l'établissement {string}") do |count, uai|
  payload = FactoryBot.build_list(:sygne_student, count)

  mock_sygne_token
  mock_sygne_students_endpoint(uai, payload)
end
