# frozen_string_literal: true

Quand("je me rend sur la page d'accueil du personnel académique") do
  visit "/academic/home"
end

Sachantque("il existe un établissement avec le code académie {string}") do |academy_code|
  school_year = SchoolYear.current
  establishment = FactoryBot.create(:establishment, academy_code: academy_code)
  classe = FactoryBot.create(:classe, establishment: establishment, school_year: school_year)

  schooling = FactoryBot.create(:schooling, classe: classe)
  FactoryBot.create(:pfmp, schooling: schooling)
end

Quand("je clique sur le nom de l'établissement dans le tableau") do
  within(".establishments-table") do
    first("a").click
  end
end

Alors("je devrais voir l'académie {string} dans les options") do |academy_code|
  academy_label = Establishment::ACADEMY_LABELS[academy_code]
  expect(page).to have_text("#{academy_label} (#{academy_code})")
end

Sachantque("il existe {int} rapports") do |count|
  school_year = SchoolYear.first || FactoryBot.create(:school_year)
  count.times { FactoryBot.create(:report, school_year: school_year) }
end

Quand("je me rends sur la page des rapports") do
  visit "/academic/reports"
end

Alors("l'URL contient {string}") do |fragment|
  expect(current_url).to include(fragment)
end

Alors("la page contient un lien vers la page de pagination {int}") do |page_number|
  expect(page).to have_link(page_number.to_s, href: /page=#{page_number}/)
end

Alors("la page ne contient pas de lien vers la page de pagination {int}") do |page_number|
  expect(page).to have_no_link(page_number.to_s, href: /page=#{page_number}/)
end

Quand("je clique sur le lien de pagination {int}") do |page_number|
  click_link(page_number.to_s, href: /page=#{page_number}/)
end

Sachantque("il existe un élève sans date de fin de scolarité pour l'académie {string}") do |academy_code|
  school_year = SchoolYear.current
  establishment = FactoryBot.create(:establishment, academy_code: academy_code)
  classe = FactoryBot.create(:classe, establishment: establishment, school_year: school_year)
  schooling = FactoryBot.create(:schooling, classe: classe)
  @student = schooling.student
end

Sachantque("une demande de paiement pour l'académie {string} a été mise à jour le {string}") do |academy_code, date|
  school_year = FactoryBot.create(:school_year)
  establishment = FactoryBot.create(:establishment, academy_code: academy_code)
  classe = FactoryBot.create(:classe, establishment: establishment, school_year: school_year)
  schooling = FactoryBot.create(:schooling, classe: classe)
  @pfmp = FactoryBot.create(:pfmp, schooling: schooling)
  payment_request = ASP::PaymentRequest.create!(pfmp: @pfmp)
  payment_request.transition_to!(:pending)
  payment_request.last_transition.update!(updated_at: Date.strptime(date, "%d/%m/%Y").in_time_zone)

  @student = payment_request.student
end

Quand("je consulte la fiche de cet élève dans l'espace académique") do
  visit academic_student_path(@student)
end

Quand("je consulte le détail de cette PFMP dans l'espace académique") do
  visit academic_student_pfmp_path(@student, @pfmp)
end

Alors("la fiche affiche le nom complet de l'élève") do
  expect(page).to have_css("h2", text: "Élève : #{@student.full_name}")
end
