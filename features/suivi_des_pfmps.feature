# language: fr

Fonctionnalité: Suivi des demandes de paiement
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je renseigne et valide une PFMP de 9 jours

  Scénario: le personnel peut ne pas voir de paiements en échecs
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement intégrée
    Et que je clique sur "Paiements"
    Alors la page ne contient pas "Liste des paiements échoués"

  Scénario: Le personnel peut voir les paiements qui ont échoués et relancer une demande de paiement
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement échouée
    Et que je clique sur "Paiements"
    Alors la page contient "Liste des paiements échoués"
    Alors la page contient "Le paiement a été refusé par l'agence comptable."
    Quand je clique sur "mars 2024"
    Et que je clique sur "Relancer une demande de paiement"
    Alors la page contient "Une nouvelle demande de paiement est en cours"

  Scénario: Le personnel peut voir les paiements qui ont été rejetés
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement rejetée
    Et que je clique sur "Paiements"
    Alors la page contient "Liste des paiements échoués"
    Alors la page contient "La demande a été rejetée :"
    Quand je clique sur "mars 2024"
    Et que je clique sur "Relancer une demande de paiement"
    Alors la page contient "Une nouvelle demande de paiement est en cours"
