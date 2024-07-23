# language: fr

Fonctionnalité: Le personnel de direction saisit des coordonnées bancaires
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "2NDEB" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Marie Curie" dans la classe de "2NDEB"

  Scénario: Le personnel de direction saisit un RIB pour la première fois
    Sachant que la page contient "Aucune coordonnée bancaire enregistrée"
    Et que je clique sur "Saisir les coordonnées bancaires"
    Et que je remplis des coordonnées bancaires
    Et que je clique sur "Enregistrer les coordonnées bancaires"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"

  Scénario: Le personnel de direction peut comprendre ses erreurs de saisie
    Sachant que je clique sur "Saisir les coordonnées bancaires"
    Et que je remplis des coordonnées bancaires
    Et que je remplis "IBAN" avec "FRAPPE"
    Et que je clique sur "Enregistrer"
    Et que la page contient "IBAN n'est pas valide"
    Quand je remplis "IBAN" avec "BR8562763198878089681604510X8"
    Et que je clique sur "Enregistrer"
    Alors la page contient "Le code IBAN ne fait pas partie de la zone SEPA"

  Scénario: Le personnel de direction peut modifier un RIB
    Sachant que je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que je clique sur "Modifier les coordonnées bancaires"
    Et que je remplis "Titulaire du compte" avec "Murie Carrie"
    Quand je clique sur "Modifier les coordonnées bancaires"
    Alors la page contient "Coordonnées bancaires mises à jour"
    Et la page contient "Murie Carrie"

  Scénario: Le personnel de direction peut supprimer un RIB
    Sachant que je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que je clique sur "Supprimer les coordonnées bancaires"
    Quand je clique sur "Confirmer la suppression"
    Alors la page contient "Les coordonnées bancaires de Marie Curie ont bien été supprimées"
    Et la page contient "Aucune coordonnée bancaire enregistrée pour le moment."

  Scénario: Quand il y a une requête de paiement en cours le personnel ne peut pas modifier un RIB
    Sachant que je renseigne et valide une PFMP de 3 jours
    Et que la dernière PFMP de "Marie Curie" en classe de "2NDEB" a une requête de paiement envoyée
    Quand je rafraîchis la page
    Alors la page contient "Ces coordonnées bancaires ne sont pas modifiables"
    Et la page contient un bouton "Modifier les coordonnées bancaires" désactivé
    Et la page contient un bouton "Supprimer les coordonnées bancaires" désactivé

  Scénario: Le personnel de direction ne peut pas modifier un RIB s'il n'est pas le dernier établissement fréquenté par l'élève
    Sachant que je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que l'élève "Marie Curie" a été transféré dans l'établissement "TEST" en classe "1EREB"
    Quand je rafraîchis la page
    Et la page contient un bouton "Modifier les coordonnées bancaires" désactivé
    Et la page contient un bouton "Supprimer les coordonnées bancaires" désactivé
