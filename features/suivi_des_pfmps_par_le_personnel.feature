# language: fr

Fonctionnalité: Suivi des demandes de paiement par le personnel
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 9 jours pour "Curie Marie"
    Et que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement échouée
    Et que je me déconnecte

  Scénario: Le personnel peut voir les paiements qui ont échoués et relancer une demande de paiement
    Sachant que je me connecte en tant que personnel autorisé de l'établissement "DINUM"
    Et que je passe l'écran d'accueil
    Lorsque je clique sur "Paiements"
    Alors la page ne contient pas "Classes à envoyer en paiement"
    Et la page contient "Le paiement a été refusé par l'agence comptable :"
    Et la page ne contient pas "Relancer une demande de paiement"

