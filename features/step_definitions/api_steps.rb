# frozen_string_literal: true

Sachantque("l'API FREGATA renvoie une liste d'élèves pour l'établissement {string}") do |uai|
  WebmockHelpers.mock_fregata_students_with(uai, FactoryBot.build_list(:fregata_student, 10))
end

Sachantque("l'API SYGNE renvoie une liste d'élèves pour l'établissement {string}") do |uai|
  WebmockHelpers.mock_sygne_token_with
  WebmockHelpers.mock_sygne_students_endpoint_with(uai, FactoryBot.build_list(:sygne_student, 10))
end

Sachantque("l'API SYGNE peut fournir les informations complètes des étudiants") do
  WebmockHelpers.mock_sygne_student_endpoint_with("", FactoryBot.build(:sygne_student_info).to_json)
end

Sachantque("les élèves de l'établissement {string} sont rafraîchis") do |uai|
  FetchStudentsJob.new(Establishment.find_by(uai: uai)).perform_now
end

Sachantque("l'API SYGNE renvoie un élève avec l'INE {string} qui a quitté l'établissement {string}") do |ine, uai|
  gone_payload = FactoryBot.build_list(:sygne_student, 1, :gone, ine: ine).to_json

  WebmockHelpers.mock_sygne_token_with
  WebmockHelpers.mock_sygne_students_endpoint_with(uai, gone_payload)
end

Sachantque("l'API SYGNE renvoie une liste d'élèves vide") do
  WebmockHelpers.mock_sygne_token_with
  WebmockHelpers.mock_sygne_students_with!([])
end
