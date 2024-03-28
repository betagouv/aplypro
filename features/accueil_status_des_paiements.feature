# language: fr

Fonctionnalité: Aperçu des paiements par status dans la page d'accueil
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "A1" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Et que je génère les décisions d'attribution de mon établissement
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours
    Quand je me rends sur la page d'accueil

  Scénario: Le personnel de direction voit une demande de paiement en attente
    Alors l'indicateur de demandes de paiements "En attente" affiche 1
    Et l'indicateur de demandes de paiements "Bloquée" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement incomplet
    Quand la tâche de préparation des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "Bloquées" affiche 1

  Scénario: Le personnel de direction voit une demande de paiement prête à être envoyée
    Et que les informations personnelles ont été récupérées pour l'élève "Marie Curie"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Quand la tâche de préparation des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 1
    Et l'indicateur de demandes de paiements "Bloquées" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement envoyée
    Et que les informations personnelles ont été récupérées pour l'élève "Marie Curie"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Quand les tâches de préparation et d'envoi des paiements sont passées
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Alors l'indicateur de demandes de paiements "En traitement" affiche 1
    Et l'indicateur de demandes de paiements "Demande rejetée" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement intégrée
    Et que les informations personnelles ont été récupérées pour l'élève "Marie Curie"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que les tâches de préparation et d'envoi des paiements sont passées
    Quand l'ASP a accepté le dossier de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 1
    Et l'indicateur de demandes de paiements "Demande rejetée" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement rejetée à l'intégration
    Et que les informations personnelles ont été récupérées pour l'élève "Marie Curie"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que les tâches de préparation et d'envoi des paiements sont passées
    Quand l'ASP a rejetté le dossier de "Marie Curie" avec un motif de "mauvais code postal"
    Et que la tâche de lecture des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Demandes rejetées" affiche 1

  Scénario: Le personnel de direction voit une demande de paiement liquidée
    Et que les informations personnelles ont été récupérées pour l'élève "Marie Curie"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que les tâches de préparation et d'envoi des paiements sont passées
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Quand l'ASP a liquidé le paiement de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Paiements envoyés" affiche 1
    Et l'indicateur de demandes de paiements "Paiements échoués" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement rejetée à la liquidation
    Et que les informations personnelles ont été récupérées pour l'élève "Marie Curie"
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que l'élève "Marie Curie" a une adresse en France et son propre RIB
    Et que les tâches de préparation et d'envoi des paiements sont passées
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Quand l'ASP n'a pas pu liquider le paiement de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Paiements envoyés" affiche 0
    Et l'indicateur de demandes de paiements "Paiements échoués" affiche 1
