# language: fr
Fonctionnalité: Gestion des paiements
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie 10 élèves dans la classe de "A1" formation "Art" dont "Marie Curie", INE "MC" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Et que je consulte la liste des classes
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"

  Scénario: Le personnel de direction peut voir un paiement planifié
    Sachant que je renseigne et valide une PFMP de 3 jours
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "Planifiée" de 30 euros

  Scénario: Le personnel de direction peut voir un paiement bloqué
    Sachant que je renseigne et valide une PFMP de 3 jours
    Et que la tâche de préparation des paiements démarre
    Et que toutes les tâches de fond sont terminées
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "Bloquée" de 30 euros

  Scénario: Le personnel de direction peut voir un paiment prêt pour l'ASP
    Sachant que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que les informations personnelles ont été récupérées pour l'élève avec l'INE "MC"
    Et que je renseigne et valide une PFMP de 3 jours
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que la tâche de préparation des paiements démarre
    Et que toutes les tâches de fond sont terminées
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "Prête" de 30 euros

  Scénario: Le personnel de direction peut voir un paiement envoyé à l'ASP
    Sachant que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que les informations personnelles ont été récupérées pour l'élève avec l'INE "MC"
    Et que je renseigne et valide une PFMP de 3 jours
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que la tâche de préparation des paiements démarre
    Et que toutes les tâches de fond sont terminées
    Et que la tâche d'envoi des paiements démarre pour toutes les requêtes prêtes à l'envoi
    Et que toutes les tâches de fond sont terminées
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En traitement" de 30 euros
