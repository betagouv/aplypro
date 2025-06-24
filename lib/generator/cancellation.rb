# frozen_string_literal: true

# rubocop:disable all
module Generator
  # Generate "Décision de retrait"
  class Cancellation < Document

    include ApplicationHelper

    private

    def margin
      34
    end

    def articles
      composer.text("Décide :", style: :paragraph_title)
      composer.text("Article 1 : Objet", style: :paragraph_title)
      composer.text("Vous avez été bénéficiaire de l’aide financière de l’Etat, dénommée « allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel », au titre de la décision d’attribution annuelle numéro #{@schooling.attributive_decision_number} en date du #{format_date(@schooling.attributive_decision.created_at)}. Cette aide est retirée pour le bénéficiaire suivant à compter du #{I18n.l(Date.today)} : ")

      composer.text("#{student.full_name}, né(e) le #{I18n.l(student.birthdate, format: :long)}, #{address_copy}, ci-après désigné « le bénéficiaire », pour l'année scolaire #{@school_year}.", style: :paragraph)

      composer.text("Article 2 : Motifs du retrait", style: :paragraph_title)
      composer.text("L’élève a été enregistré dans la base élève de l’établissement mais ne s’est jamais inscrit à une formation dans l’établissement et ne s’est jamais présenté, il est procédé à une décision de retrait de la décision d’attribution annuelle réalisée par l’établissement.", style: :paragraph)

      composer.text("Le montant initialement calculé ne correspondant pas à la situation de l’élève, il est procédé à une décision de retrait de la décision d’attribution annuelle.", style: :paragraph)

      composer.text("Article 3 : Implications du retrait", style: :paragraph_title)
      composer.text("Le retrait de la décision d’attribution annuelle de l’allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel entraîne la fin du versement des montants initialement prévus.", style: :paragraph)

      composer.text("Article 4 : Litiges", style: :paragraph_title)
      composer.text("En cas de contestation de la décision le bénéficiaire peut exercer un recours gracieux ou hiérarchique auprès du recteur dans un délai de 2 mois à compter de la notification de cette décision.", style: :paragraph)

      composer.text("Dans le même délai de deux mois à compter de la notification de cette décision le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif compétant pour l’établissement.", style: :paragraph)

      composer.text("Si un recours gracieux ou hiérarchique a été exercé le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif compétant pour l’établissement dans un délai de deux mois à compter de la réponse ou du rejet implicite du recours gracieux ou hiérarchique par l’autorité compétente.", style: :paragraph)

      composer.text("Retrait de la décision d’attribution éditée le #{I18n.l(Date.today)} par validation informatique du responsable légal de l'établissement.", style: :paragraph)
    end

    def header
      composer.image(Rails.root.join("app/assets/images/Republique_Francaise_RVB.png").to_s, height: 100, position: :float)
      composer.text("Retrait de la décision d'attribution annuelle".upcase, style: :title, margin: [150, 0, 0, 0])
      composer.text("Relative au versement d’une allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel".upcase, style: :subtitle)
      composer.text("année scolaire #{@school_year}".upcase, style: :subtitle, margin: [10, 0, 50, 0])
    end

    def summary
      establishment = @schooling.establishment

      director = establishment.confirmed_director || establishment.users.directors.first

      composer.text("Numéro de dossier administratif : #{@schooling.administrative_number}", style: :paragraph)
      composer.text("Numéro de décision attributive annuelle : #{@schooling.attributive_decision_number}", style: :paragraph)
      composer.text("Bénéficiaire : #{student.full_name}", style: :paragraph)
      composer.text("Adresse email de l'établissement : #{establishment.email}", style: :paragraph)
      composer.text("Téléphone de l'établissement : #{establishment.telephone}", style: :paragraph)
      composer.text("#{director.name}, représentant légal de l’établissement d’enseignement #{establishment.name}, (#{establishment.uai}), sis #{establishment.address}.", style: :paragraph)
    end
  end
end
# rubocop:enable all
