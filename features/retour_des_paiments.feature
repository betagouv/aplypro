# language: fr
Fonctionnalité: Gestion des retours de l'ASP
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie 10 élèves dans la classe de "A1" formation "Art" dont "Marie Curie", INE "MC" pour l'établissement "DINUM"
    Et que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que les informations personnelles ont été récupérées pour l'élève avec l'INE "MC"
    Et que je passe l'écran d'accueil
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours
    Et que les tâches de préparation et d'envoi des paiements sont passées
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"

  Scénario: Il n'y a pas de fichiers sur le serveur de l'ASP
    Sachant qu'il n'y a pas de fichiers sur le serveur de l'ASP
    Et que la tâche de lecture des paiements démarre
    Et que toutes les tâches de fond sont terminées
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En traitement" de 30 euros

  Scénario: L'individu n'a pas pu être intégré sur le serveur de l'ASP
    Et que l'ASP a rejetté le dossier de "Marie Curie" avec un motif de "mauvais code postal"
    Quand la tâche de lecture des paiements démarre
    Et que toutes les tâches de fond sont terminées
    Et que je consulte la dernière PFMP
    Alors la page contient "Demande rejetée"
    Et la page contient "mauvais code postal"

  Scénario: L'individu a été intégré sur le serveur de l'ASP
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Quand la tâche de lecture des paiements est passée
    Et que je consulte la dernière PFMP
    Alors la page contient "La demande a été intégrée"

  Scénario: Le paiement a été liquidé sur le serveur de l'ASP
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Quand la tâche de lecture des paiements est passée
    Et que l'ASP a liquidé le paiement de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que je consulte la dernière PFMP
    Alors la page contient "Paiement envoyé"

  Scénario: Le paiement n'a pas pu être liquider sur le serveur de l'ASP
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Quand la tâche de lecture des paiements est passée
    Et que l'ASP n'a pas pu liquider le paiement de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que je consulte la dernière PFMP
    Alors la page contient "Paiement échoué"