# language: fr

Fonctionnalité: Aperçu des paiements par status dans la page d'accueil
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "ETAB3000"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie 10 élèves dans la classe de "A1" formation "Art" dont "Marie Curie", INE "MC3000" pour l'établissement "ETAB3000"
    Et que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours
    # Et que les tâches de préparation et d'envoi des paiements sont passées
    Quand je me rends sur la page d'accueil

  Scénario: Le personnel de direction voit un paiement en attente pour une PFMP validée
    Alors l'indicateur de demandes de paiements "En attente" affiche 1
    Et l'indicateur de demandes de paiements "Bloquée" n'est pas affiché

  Scénario: Le personnel de direction voit un paiement en échec pour un paiement incomplete
    Et que la tâche de préparation des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "Bloquées" affiche 1

  Scénario: Le personnel de direction voit un paiement en attente pour un paiement prêt à être envoyé 
    Sachant que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que les informations personnelles ont été récupérées pour l'élève avec l'INE "MC3000"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que la tâche de préparation des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 1
    Et l'indicateur de demandes de paiements "Bloquées" n'est pas affiché