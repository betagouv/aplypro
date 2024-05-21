# frozen_string_literal: true

require "hexapdf"

# rubocop:disable all
module AttributeDecision
  class Abrogator
    include ActionView::Helpers::NumberHelper

    attr_reader :composer, :schooling, :student

    def initialize(schooling)
      @composer = HexaPDF::Composer.new(page_size: :A4, margin: 48)

      @schooling = schooling
      @student = schooling.student
    end

    def generate!(file_descriptor)
      composer.write(file_descriptor)
    end

    private

    def render
      student = @schooling.student

      setup_styles!

      header
      summary
      legal

      composer.text("Décide :", style: :paragraph_title)
      composer.text("Article 1 : Objet", style: :paragraph_title)
      composer.text("Une aide financière de l’État, dénommée « allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel », est abrogée à :")

      composer.text("#{student.full_name}, né(e) le #{I18n.l(student.birthdate, format: :long)}, résidant au #{address_copy}, ci-après désigné « le bénéficiaire », pour l'année scolaire 2023-2024.", style: :paragraph)

      composer.text("Article 2 : Motifs d’abrogation", style: :paragraph_title)
      composer.text("Changement de formation :", style: :paragraph)
      composer.text("L’élève ayant changé de formation il remplit les conditions d’abrogation mentionnées dans l’article 6 de la décision d’attribution mentionnée ci-dessus.", style: :paragraph)

      composer.text("Changement d’établissement / Sortie de l’établissement :", style: :paragraph)
      composer.text("L’élève ayant quitté l’établissement il remplit les conditions d’abrogation mentionnées dans l’article 6 de la décision d’attribution mentionnée ci-dessus.", style: :paragraph)

      composer.text("Article 3 : Implications de l’abrogation", style: :paragraph_title)
      composer.text("L’abrogation de la décision d’attribution annuelle de l’allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel entraîne la fin du versement des montants initialement dus en vertu de la décision abrogée.", style: :paragraph)

      composer.text("Article 4 : Litiges", style: :paragraph_title)
      composer.text("En cas de contestation de la décision le bénéficiaire peut exercer un recours gracieux ou hiérarchique auprès du recteur dans un délai de 2 mois à compter de la notification de cette décision.", style: :paragraph)

      composer.text("Dans le même délai de deux mois à compter de la notification de cette décision le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif de l’établissement.", style: :paragraph)

      composer.text("Si un recours gracieux ou hiérarchique a été exercé le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif de l’établissement dans un délai de deux mois à compter de la réponse ou du rejet implicite du recours gracieux ou hiérarchique par l’autorité compétente.", style: :paragraph)

      composer.text("Abrogation de décision d’attribution éditée le #{I18n.l(Date.today)} par validation informatique du responsable légal de l'établissement.", style: :paragraph)
    end

    def setup_styles!
      composer.style(:base, font: "Times", font_size: 10, line_spacing: 1.4, last_line_gap: true, margin: [3, 0, 0, 0])
      composer.style(:title, font: ["Times", variant: :bold], font_size: 12, align: :center, padding: [10, 0])
      composer.style(:direction, font_size: 12, align: :right)
      composer.style(:subtitle, align: :center, padding: [0, 30], line_height: 12)
      composer.style(:paragraph_title, font: ["Times", variant: :bold], font_size: 10, margin: [10, 0, 0, 0])
      composer.style(:paragraph, font_size: 10, margin: [5, 0, 0, 0])
      composer.style(:legal, font: ["Times", variant: :italic], padding: [10, 0, 0, 0])
    end

    def header
      composer.image(Rails.root.join("app/assets/images/Republique_Francaise_RVB.png").to_s, height: 100, position: :float)
      composer.text("Abrogation de décision d'attribution annuelle".upcase, style: :title, margin: [150, 0, 0, 0])
      composer.text("Relative au versement d’une allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel".upcase, style: :subtitle)
      composer.text("année scolaire 2023 - 2024".upcase, style: :subtitle, margin: [10, 0, 50, 0])
    end

    def summary
      establishment = @schooling.establishment

      director = establishment.confirmed_director || establishment.users.directors.first

      composer.text("Numéro de dossier administratif : #{schooling.administrative_number}", style: :paragraph)
      composer.text("Numéro de décision attributive : #{schooling.attributive_decision_number}", style: :paragraph)
      composer.text("Bénéficiaire : #{student.full_name}", style: :paragraph)
      composer.text("Adresse email de l'établissement : #{establishment.email}", style: :paragraph)
      composer.text("Téléphone de l'établissement : #{establishment.telephone}", style: :paragraph)
      composer.text("#{director.name}, représentant légal de l’établissement d’enseignement #{establishment.name}, (#{establishment.uai}), sis #{establishment.address}.", style: :paragraph)
    end

    def legal
      I18n.t("attributive_decision.legal").map { |line| composer.text("#{line} ;", style: :legal) }
    end

    def address_copy
      if student.missing_address?
        I18n.t("attributive_decision.missing_address")
      else
        I18n.t("attributive_decision.address", address: student.address)
      end
    end
  end
end
# rubocop:enable all
