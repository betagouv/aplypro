# frozen_string_literal: true

# rubocop:disable all
  module Generator
  # Generate "Décision d'attribution"
  class Attributor < Document
    private

    def articles
      composer.text("Décide : ", style: :paragraph_title)
      composer.text("Article 1 : Objet", style: :paragraph_title)
      composer.text("Une aide financière de l’État, dénommée « allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel », est attribuée à : ")

      composer.text("#{student.full_name}, né(e) le #{I18n.l(student.birthdate)}, #{address_copy}, ci-après désigné « le bénéficiaire », inscrit en « #{@schooling.mef.label} (MEF : #{@schooling.mef.code}) » pour l'année scolaire #{@school_year}.")

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

      composer.text("Dans le même délai de deux mois à compter de la notification de cette décision, le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif compétant pour l’établissement.")

      composer.text("Si un recours gracieux ou hiérarchique a été exercé, le bénéficiaire peut exercer un recours contentieux devant le tribunal administratif compétant pour l’établissement dans un délai de deux mois à compter de la réponse ou du rejet implicite du recours gracieux ou hiérarchique par l’autorité compétente.")

      composer.text("Article 9 : Reversement", style: :paragraph_title)

      composer.text("Dans le cas où il serait constaté des sommes indument versées au bénéficiaire, l’Agence de Services et de Paiement (ASP) pourra procéder notamment à la demande de l’établissement au recouvrement total ou partiel de l’allocation perçue.")

      composer.text("Article 10 : Mentions informatives auprès du public relatif au système d’information APLyPro", style: :paragraph_title)



      composer.text("Finalités", style: :paragraph_title, underline: true)
      composer.text(
        "L’application informatique ApLyPro permet le versement d’une allocation en faveur des lycéens de la
        voie professionnelle inscrits dans des formations professionnelles des ministères chargés de
        l'éducation nationale, de l'agriculture et de la mer, de niveau 3 et 4, afin de valoriser leurs périodes de
        formation en milieu professionnel. Les informations recueillies dans le cadre de ce traitement sont
        également utilisées à des fins statistiques."
      )

      composer.text("Base légale", style: :paragraph_title, underline: true)
      composer.text("La base légale sur laquelle se fonde le traitement est la suivante :")
      composer.list do |list|
        list.text("Décret n° 2023-765 du 11 août 2023 relatif au versement d'une allocation en faveur des lycéens de
          la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel ;")
        list.text("Arrêté du 11 août 2023 déterminant les montants et les conditions de versement de l'allocation aux
          lycéens de la voie professionnelle engagés dans des périodes de formation en milieu professionnel")
      end
      composer.text(
        "Cette application informatique constitue un traitement de données à caractère personnel mis en
        œuvre par le ministère chargé de l’éducation nationale pour l’ensemble des lycées professionnels des
        ministères chargés de l'éducation, de l'agriculture et de la mer, des formations professionnelles de
        niveau 3 et 4, pour le respect d'une obligation légale à laquelle le responsable du traitement est soumis
        au sens du c) du 1 de l’article 6 du Règlement (UE) 2016/679 du Parlement européen et du Conseil du
        27 avril 2016 relatif à la protection des personnes physiques à l'égard du traitement des données à
        caractère personnel et à la libre circulation de ces données (RGPD)."
      )
      composer.text(" Le ministère s'engage à ce que la collecte et le traitement de vos données à caractère personnel, effectués à partir de l’application informatique ApLyPro, soient conformes à ce règlement.")

      composer.text("Données traitées et durées de conservation", style: :paragraph_title, underline: true)
      composer.text(
        "La présente décision a été prise sur le fondement d’un traitement algorithmique.
        Ce traitement permet : d’une part, de calculer le montant de l’allocation de stage, en prenant en compte
        la durée de la PFMP (date de début et date de fin) et le barème associé au nombre de jours de PFMP effectués."
      )
      composer.text(
        "D’autre part, de s’assurer de la cohérence des données saisies, nécessaires au paiement de l’allocation
        de stage, en prenant en compte : les coordonnées bancaires, l’information minimale concernant la domiciliation,
        l’identité et l’âge du bénéficiaire, l’éligibilité de l’élève à percevoir l’allocation de stage."
      )
      composer.text(
        "En application de l’article R. 311-3-1-1 et R. 311-3-1-2 du code des relations entre le public et
        l’administration, vous pouvez demander la communication des règles définissant ce traitement et leur mise
        en œuvre dans votre cas auprès du Délégué à la protection des données du ministère chargé de l'éducation
        nationale (dpd@education.gouv.fr). En cas d’absence de réponse dans un délai d’un mois à la suite de la
        réception de votre demande par nos services, vous disposez d'un délai de deux mois pour saisir la Commission
        d'accès aux documents administratifs (CADA) selon les modalités décrites sur le site web www.cada.fr"
      )
      composer.text(
        "Pour les élèves scolarisés dans les établissements dépendant du ministère en charge de l’éducation
        nationale ou du ministère chargé de la mer, le numéro INE, les nom, prénoms, l’adresse,
        l’établissement, le module élémentaire de formation et la classe proviennent du traitement SYGNE
        (référentiel des élèves du second degré)."
      )
      composer.text(
        "Pour les élèves scolarisés dans les établissements dépendant du ministère en charge de l’agriculture,
        le numéro INE, les nom, prénoms, l’adresse, l’établissement, le module élémentaire de formation et la
        classe proviennent du traitement FREGATA mis en œuvre sous la responsabilité du ministère chargé
        de l’agriculture."
      )
      composer.text(
        "Pour les représentants légaux, les titulaires d’un compte autre que les élèves bénéficiaires (tiers
        physique, tiers moral), les noms, prénoms, les données bancaires, l’adresse postale, le consentement
        du représentant légal lorsque l’élève est mineur pour la destination bancaire du versement de
        l’allocation sont issues des pièces justificatives collectées en début d’année scolaire. Ces données sont
        nécessaires au paiement."
      )
      composer.text("Vos données sont conservées pour une durée de 10 ans à compter de leur collecte.")

      composer.text("Destinataires", style: :paragraph_title, underline: true)
      composer.text(
        "Les destinataires de vos données sont le chef ou directeur d’établissement, l’adjoint au chef
        d’établissement, le personnel de l’établissement désigné par le chef d’établissement en charge de la
        saisie de vos données, les administrateurs du système d’information en administration centrale et en
        académie, le personnel du pôle de diffusion nationale, qui assure l’assistance de l’application, la
        direction du numérique éducatif (DNE) qui assure la gestion technique de l’application et de l’agence
        de services et de paiement (ASP) qui assure le paiement de l’allocation."
      )

      composer.text("Droit des personnes", style: :paragraph_title, underline: true)
      composer.text(
        "Vous pouvez exercer vos droits d’accès, de rectification et de limitation prévus par les articles 15, 16
        et 18 du RGPD auprès du chef d’établissement, sur place, par voie postale ou par voie électronique.
        Les droits à l’effacement et à l’opposition ne s’appliquent pas au présent traitement."
      )
      composer.text("De la même manière, vous pouvez exercer les droits prévus à l’article 85 de la loi n° 78-17 du 6 janvier 1978 relative à l’informatique, aux fichiers et aux libertés.")
      composer.text(
        "Pour exercer vos droits ou pour toute autre question sur le traitement de vos données à caractère
        personnel, vous pouvez aussi contacter le délégué à la protection des données du ministère chargé de
        l’éducation nationale:")
      composer.list do |list|
        list.text("à l’adresse électronique suivante : dpd@education.gouv.fr")
        list.text("par courrier en vous adressant au :
            Ministère chargé de l'éducation nationale
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
      composer.text(
        "À l’occasion de ces démarches, vous devez justifier de votre identité par tout moyen. En cas de doute
        sur votre identité, les services chargés du droit d’accès et le délégué à la protection des données
        peuvent vous demander les informations supplémentaires qui leur apparaissent nécessaires, y compris
        la photocopie d’un titre d’identité portant votre signature."
      )

      composer.text("Décision d’attribution éditée le #{I18n.l(Date.today)} par validation informatique du responsable légal de l'établissement qui a collecté et vérifié les pièces jointes relatives à l’identité de l’élève bénéficiaire de l’allocation afin de valider la procédure de versement de l’allocation.")
    end

    def header
      header_initializer("Décision d'attribution annuelle")
    end

    def summary
      establishment = @schooling.establishment

      director = establishment.confirmed_director || establishment.users.directors.first

      composer.text("Numéro de dossier administratif : #{schooling.administrative_number}")
      composer.text("Numéro de décision attributive annuelle : #{schooling.attributive_decision_number}")
      composer.text("Bénéficiaire : #{student}")
      composer.text("Adresse email de l'établissement : #{establishment.email}")
      composer.text("Téléphone de l'établissement : #{establishment.telephone}")
      composer.text("#{director.name}, représentant légal de l’établissement d’enseignement #{establishment.name}, (#{establishment.uai}), sis #{establishment.address}, ci-après désigné « l’établissement ».")
    end
  end
end
# rubocop:enable all
