# language: fr

Fonctionnalité: Le personnel de direction saisit des coordonnées bancaires
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "2NDEB" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Curie Marie" dans la classe de "2NDEB"

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
    Sachant que je renseigne les coordonnées bancaires de l'élève "Curie Marie" de la classe "2NDEB"
    Et que je clique sur "Modifier les coordonnées bancaires"
    Et que je remplis "Titulaire du compte" avec "Murie Carrie"
    Quand je clique sur "Modifier les coordonnées bancaires"
    Alors la page contient "Coordonnées bancaires mises à jour"
    Et la page contient "Murie Carrie"

  Scénario: Le personnel de direction peut relancer une demande de paiement en modifiant les coordonnées bancaires
    Quand je consulte la classe de "2NDEB"
    Et que je renseigne et valide une PFMP de 9 jours pour "Curie Marie"
    Sachant que la dernière PFMP de "Curie Marie" en classe de "2NDEB" a une requête de paiement envoyée
    Et que l'ASP a rejetté le dossier de "Curie Marie" avec un motif de "Le pays correspondant au code BIC 1234 n'autorise pas le mode de réglement SEPA"
    Et que la tâche de lecture des paiements est passée
    Quand je clique sur "Modifier les coordonnées bancaires"
    Et que je clique sur "Modifier les coordonnées bancaires"
    Et la page contient "Les nouvelles coordonnées bancaires ne peuvent pas être enregistrées car aucune information n'a été modifiée"
    Quand je clique sur "Modifier les coordonnées bancaires"
    Et que je remplis "Titulaire du compte" avec "Luigi Curie"
    Et que je clique sur "Modifier les coordonnées bancaires"
    Alors la page contient "Modifier les coordonnées bancaires"

  Scénario: Le personnel de direction ne peut pas accéder au RIB d'un élève s'il a été déclaré dans un autre établissement
    Sachant que je renseigne les coordonnées bancaires de l'élève "Curie Marie" de la classe "2NDEB"
    Et que l'élève "Curie Marie" a été transféré dans l'établissement "TEST" en classe "1EREB"
    Alors la page contient "Modifier les coordonnées bancaires"
    Quand je me déconnecte
    Et que je suis un personnel MENJ directeur de l'établissement "TEST"
    Sachant que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que je consulte le profil de "Curie Marie" dans la classe de "1EREB"
    Alors la page contient "Aucune coordonnée bancaire enregistrée"
