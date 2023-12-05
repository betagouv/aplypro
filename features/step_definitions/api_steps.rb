# frozen_string_literal: true

# NOTE: l'API SYGNE est stateful : parce qu'un élève manquant est un
# élève déscolarisé, il nous faut renvoyer les élèves précédents sous
# peine de les voir disparaître, d'où @sygne_results.

Sachantque(
  "l'API SYGNE renvoie {int} élèves en {string} dont l'INE {string} pour l'établissement {string}"
) do |count, classe, ine, uai|
  @sygne_results = []

  WebmockHelpers.mock_sygne_token_with

  payload = FactoryBot.build_list(:sygne_student, count, classe: classe).tap do |students|
    students.last["ine"] = ine
  end

  @sygne_results << payload

  WebmockHelpers.mock_sygne_students_endpoint_with(uai, payload)
end

Sachantque("l'API FREGATA renvoie une liste d'élèves pour l'établissement {string}") do |uai|
  WebmockHelpers.mock_fregata_students_with(uai, FactoryBot.build_list(:fregata_student, 10))
end

Sachantque("l'API SYGNE peut fournir les informations complètes des étudiants") do
  WebmockHelpers.mock_sygne_student_endpoint_with("", FactoryBot.build(:sygne_student_info).to_json)
end

Sachantque("les élèves de l'établissement {string} sont rafraîchis") do |uai|
  FetchStudentsJob.new(Establishment.find_by(uai: uai)).perform_now
end

Sachantque("l'API SYGNE renvoie un élève avec l'INE {string} qui a quitté l'établissement {string}") do |ine, uai|
  payload_without_student = @sygne_results.last.dup.reject { |student| student["ine"] == ine }

  WebmockHelpers.mock_sygne_token_with
  WebmockHelpers.mock_sygne_students_endpoint_with(uai, payload_without_student)
end

Sachantque("l'API SYGNE renvoie {int} nouvel/nouveaux élève(s) pour l'établissement {string}") do |count, uai|
  payload = FactoryBot.build_list(:sygne_student, count)

  WebmockHelpers.mock_sygne_token_with
  WebmockHelpers.mock_sygne_students_endpoint_with(uai, payload)
end
