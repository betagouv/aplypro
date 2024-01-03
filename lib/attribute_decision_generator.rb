# frozen_string_literal: true

# rubocop:disable all
class AttributeDecisionGenerator
  include ActionView::Helpers::NumberHelper

  attr_reader :composer, :schooling, :student

  def initialize(schooling)
    @composer = HexaPDF::Composer.new(page_size: :A4, margin: 48)

    @schooling = schooling
    @student = schooling.student
  end

  def generate!(file_descriptor)
    Schooling.transaction do
      schooling.increment!(:attributive_decision_version)

      render

      composer.write(file_descriptor)
    end
  end

  private

  def render
    student = @schooling.student

    setup_styles!

    header
    summary
    legal

    composer.text("Décide : ", style: :paragraph_title)
    composer.text("Article 1 : Objet", style: :paragraph_title)
    composer.text("Une aide financière de l’État, dénommée « allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel », est attribuée à : ")

    composer.text("#{student.full_name}, né(e) le #{I18n.l(student.birthdate)}, #{address_copy}, ci-après désigné « le bénéficiaire », inscrit en « #{@schooling.mef.label} (MEF : #{@schooling.mef.code}) » pour l'année scolaire 2023-2024.")

    composer.text("Article 2 : Conditions d’éligibilité à l’allocation", style: :paragraph_title)
    composer.text("Cette allocation a pour objectif de reconnaître l’engagement des lycéens professionnels dans la réalisation de leur formation en valorisant les périodes de formation en milieu professionnel (PFMP).")

    composer.text("Sont ainsi éligibles à cette allocation :")

    composer.list do |list|
      list.text("les lycéens professionnels inscrits en formation initiale et sous statut scolaire dans les établissements et organismes de formation publics ou privés sous contrat d’association ET")
      list.text("qui préparent un diplôme professionnel de niveau 3 ou 4 délivré par le ministère chargé de l’éducation, de l’agriculture ou de la mer ou inscrits au titre d’une action d’adaptation professionnelle ET")
      list.text("qui réalisent des PFMP encadrées par une convention de stage.")
    end

    composer.text("Article 3 : Conditions d’attribution et de versement", style: :paragraph_title)

    composer.text("Le bénéfice de l’allocation attribuée est soumis à la réalisation effective de PFMP encadrées par une convention de stage.")

    composer.text("Les versements interviennent à l’issue de chaque PFMP, ou à l’issue de 3 mois de PFMP pour les conventions qui excèdent cette durée, sur la base du nombre de jours de stage réalisés indiqué sur l’attestation de fin de stage délivrée par le lieu d’accueil de la PFMP à l’élève et à l’établissement.")

    composer.text("Le montant de l’allocation due pour chaque PFMP est calculé selon les modalités suivantes :")

    composer.text("Nombre de jours de PFMP réalisés × #{number_to_currency(@schooling.mef.wage.daily_rate)}", align: :center)

    composer.text("Article 4 : Montant maximal accordé", style: :paragraph_title)

    composer.text("Par la présente décision, l’État vous attribue l’allocation maximale annuelle prévisionnelle suivante :")

    composer.text("#{I18n.t('ministries.' + @schooling.mef.ministry)} : #{number_to_currency(schooling.mef.wage.yearly_cap)}", align: :center)

    composer.text("Article 5 : Modalité de versement de l’allocation", style: :paragraph_title)

    composer.text("Sur la base des éléments transmis par l’établissement, l’Agence de Services et de Paiement (ASP) procède au versement de l’allocation due sur les coordonnées bancaires choisies par le bénéficiaire ou son représentant légal pour le paiement et transmis par l’établissement.")

    composer.text("Article 6 : Engagements du bénéficiaire et conditions d’abrogation de la présente décision", style: :paragraph_title)

    composer.text("Le bénéficiaire s’engage à :")

    composer.list do |list|
      list.text("réaliser les PFMP prévues dans sa formation ;")
      list.text("fournir toutes les pièces justificatives demandées par l’établissement ;")
      list.text("informer l’établissement de tout changement de ses coordonnées bancaires pour le paiement ; à défaut, les versements de l’allocation pourraient être interrompus ;")
      list.text("déclarer auprès de l’administration fiscale l’allocation perçue si ses revenus d’activité en cours d’étude, allocation comprise, au titre d’une année excèdent trois SMIC mensuels ou s’il a plus de 25 ans ;")
      list.text("signaler à l’établissement toute erreur constatée dans le traitement de sa demande.")
    end

    composer.text("Toutes pièces justificatives, y compris complémentaires pourront être réclamées au bénéficiaire, y compris postérieurement au paiement afin de contrôler la véracité de ses déclarations ou à des fins de lutte anti-fraude.")

    composer.text("S’il s’avère que ces conditions ne sont pas ou plus remplies, ou que l’élève change de formation ou quitte l’établissement l’allocation peut être abrogée.")

    composer.text("Article 7 : Conservation des documents et contrôles", style: :paragraph_title)

    composer.text("Le bénéficiaire est informé que l’établissement conservera l’ensemble des documents et éléments relatifs à l’attribution de son allocation en faveur des lycéens professionnels dans le cadre de la valorisation des périodes de formation en milieu professionnel pendant une période au moins égale à 10 ans à la fin de l’année scolaire mentionnée à l’article 1 de la présente décision d’attribution.")

    composer.text("Dans le cadre de contrôles ou d’audits, l’établissement pourra se rapprocher du bénéficiaire afin d’obtenir des éléments complémentaires jusqu’à 10 ans après la fin de l’année scolaire mentionnée à l'article 1 de la présente décision d'attribution.")

    composer.text("Article 8 : Litiges", style: :paragraph_title)

    composer.text("En cas de contestation de la décision, le bénéficiaire peut exercer un recours gracieux ou hiérarchique auprès du recteur dans un délai de 2 mois à compter de la notification de cette présente décision.")

    composer.text("Dans le même délai de deux mois à compter de la notification de cette décision, le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif de l’établissement.")

    composer.text("Si un recours gracieux ou hiérarchique a été exercé, le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif de l’établissement dans un délai de deux mois à compter de la réponse ou du rejet implicite du recours gracieux ou hiérarchique par l’autorité compétente.")

    composer.text("Article 9 : Reversement", style: :paragraph_title)

    composer.text("Dans le cas où il serait constaté des sommes indument versées au bénéficiaire, l’Agence de Services et de Paiement (ASP) pourra procéder notamment à la demande de l’établissement au recouvrement total ou partiel de l’allocation perçue.")

    composer.text("Article 10 : Mentions informatives auprès du public relatif au système d’information APLyPro", style: :paragraph_title)

    composer.text("Finalités", style: :paragraph_title)
    composer.text("L’application informatique APLyPro permet le versement d’une allocation en faveur des lycéens de la voie professionnelle inscrits dans des formations professionnelles des ministères chargés de l'éducation nationale, de l'agriculture et de la mer, de niveau 3 et 4, afin de valoriser leurs périodes de formation en milieu professionnel.")
    composer.text("Les informations recueillies dans le cadre de ce traitement sont également utilisées à des fins statistiques.")

    composer.text("Base légale", style: :paragraph_title)
    composer.text("Cette application informatique constitue un traitement de données à caractère personnel mis en œuvre par le Ministère de l’Éducation Nationale et de la Jeunesse pour l’ensemble des lycées professionnels des ministères chargés de l'éducation, de l'agriculture et de la mer, de formations professionnelles de niveau 3 et 4, pour le respect d'une obligation légale à laquelle le responsable du traitement est soumis au sens du c) du 1 de l’article 6 du règlement général sur la protection des données (RGPD).")
    composer.text("Le ministère s'engage à ce que la collecte et le traitement de vos données à caractère personnel, effectués à partir de l’application informatique APLyPro, soient conformes à ce règlement.")

    composer.text("Données traitées et durées de conservation", style: :paragraph_title)
    composer.text("Les données proviennent :")

    composer.list do |list|
      list.text("pour les élèves scolarisés dans les établissements dépendant du ministère en charge de l’éducation nationale ou du ministère en charge de la mer, du traitement SYGNE (référentiel des élèves du second degré) ;")
      list.text("pour les élèves scolarisés dans les établissements dépendant du ministère en charge de l’agriculture, du traitement FREGATA.")
    end

    composer.text("Vos données sont conservées pour une durée de 10 ans à compter de leur collecte.")

    composer.text("Destinataires", style: :paragraph_title)
    composer.text("Les destinataires de vos données sont les agents de la Direction Interministérielle du Numérique (DINUM), les administrateurs du système d’information en administration centrale et en académie, personnel du pôle de diffusion nationale, qui assurent l’assistance de l’application, et de l’Agence de Services et de Paiement (ASP) qui assure le paiement de l’allocation.")

    composer.text("Droit des personnes", style: :paragraph_title)
    composer.text("Vous pouvez exercer vos droits d’accès, de rectification et de limitation prévus par les articles 15, 16 et 18 du RGPD, et sur le fondement de l'obligation légale, auprès du chef d’établissement, sur place, par voie postale ou par voie électronique. Les droits à l’effacement et à l’opposition ne s’appliquent pas au présent traitement.")
    composer.text("De la même manière, vous pouvez exercer les droits prévus à l’article 85 de la loi n° 78-17 du 6 janvier 1978 relative à l’informatique, aux fichiers et aux libertés.")
    composer.text("Pour exercer vos droits ou pour toute autre question sur le traitement de vos données à caractère personnel, vous pouvez aussi contacter le délégué à la protection des données du ministère de l’éducation nationale, de la jeunesse et des sports :")

    composer.list do |list|
      list.text("à l’adresse électronique suivante : dpd@education.gouv.fr")
      list.text("par courrier en vous adressant au :

          Ministère de l'Éducation Nationale et de la Jeunesse
          À l'attention du délégué à la protection des données (DPD)
          110 rue de Grenelle
          75357 Paris Cedex 07")
    end

    composer.text("Si vous estimez, après nous avoir contactés, que vos droits ne sont pas respectés, vous pouvez adresser une réclamation à la CNIL :")

    composer.list do |list|
      list.text("via le formulaire de saisine en ligne : https://www.cnil.fr/fr/vous-souhaitez-contacter-la-cnil")
      list.text("ou par courrier postal, à l’adresse :
      Commission nationale de l'informatique et des libertés
      3 Place de Fontenoy
      TSA 80715
      75334 Paris Cedex 07")
    end

    composer.text("À l’occasion de ces démarches, vous devez justifier de votre identité par tout moyen. En cas de doute sur votre identité, les services chargés du droit d’accès et le délégué à la protection des données peuvent vous demander les informations supplémentaires qui leur apparaissent nécessaires, y compris la photocopie d’un titre d’identité portant votre signature.")

    composer.text("Décision d’attribution éditée le #{I18n.l(Date.today)} par validation informatique du responsable légal de l'établissement qui a collecté et vérifié les pièces jointes relatives à l’identité de l’élève bénéficiaire de l’allocation afin de valider la procédure de versement de l’allocation.")
  end

  def setup_styles!
    composer.style(:base, font: "Times", font_size: 10, line_spacing: 1.4, last_line_gap: true, margin: [3, 0, 0, 0])
    composer.style(:title, font: ["Times", variant: :bold], font_size: 12, align: :center, padding: [10, 0])
    composer.style(:direction, font_size: 12, align: :right)
    composer.style(:subtitle, align: :center, padding: [0, 30], line_height: 12)
    composer.style(:paragraph_title, font: ["Times", variant: :bold], font_size: 10, margin: [10, 0, 0, 0])
    composer.style(:legal, font: ["Times", variant: :italic], padding: [10, 0, 0, 0])
  end

  def header
    composer.image(Rails.root.join("app/assets/images/Republique_Francaise_RVB.png").to_s, height: 100, position: :float)
    composer.text("Décision d'attribution annuelle".upcase, style: :title, margin: [150, 0, 0, 0])
    composer.text("Relative au versement d’une allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel".upcase, style: :subtitle)
    composer.text("année scolaire 2023 - 2024".upcase, style: :subtitle, margin: [10, 0, 50, 0])
  end

  def summary
    establishment = @schooling.establishment

    director = establishment.users.confirmed_director || establishment.users.directors.first

    composer.text("Numéro de dossier administratif : #{student.asp_file_reference}")
    composer.text("Numéro de décision attributive : #{schooling.attributive_decision_number}")
    composer.text("Bénéficiaire : #{student}")
    composer.text("Adresse email de l'établissement : #{establishment.email}")
    composer.text("Téléphone de l'établissement : #{establishment.telephone}")
    composer.text("#{director.name}, représentant légal de l’établissement d’enseignement #{establishment.name}, (#{establishment.uai}), sis #{establishment.address}, ci-après désigné « l’établissement ».")
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
# rubocop:enable all
