# language: fr

Fonctionnalité: Aperçu des paiements par status dans la page d'accueil
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "A1" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Et que l'élève "Marie Curie" en classe de "A1" a toutes les informations nécessaires pour le paiement
    Et que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours pour "Marie Curie"
    Quand je me rends sur la page d'accueil

  Scénario: Le personnel de direction voit une demande de paiement en attente
    Alors l'indicateur de demandes de paiements "En attente" affiche 1
    Et l'indicateur de demandes de paiements "Bloquée" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement incomplet
    Sachant que l'élève "Marie Curie" n'a pas d'INE
    Et que la tâche de préparation des paiements est passée
    Et que je me rends sur la page d'accueil
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "Bloquées" affiche 1

  Scénario: Le personnel de direction voit une demande de paiement prête à être envoyée
    Quand la tâche de préparation des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 1
    Et l'indicateur de demandes de paiements "Bloquées" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement envoyée
    Quand les tâches de préparation et d'envoi des paiements sont passées
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Alors l'indicateur de demandes de paiements "En traitement" affiche 1
    Et l'indicateur de demandes de paiements "Demande rejetée" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement intégrée
    Sachant que les tâches de préparation et d'envoi des paiements sont passées
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 1
    Et l'indicateur de demandes de paiements "Demande rejetée" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement rejetée à l'intégration
    Sachant que les tâches de préparation et d'envoi des paiements sont passées
    Et que l'ASP a rejetté le dossier de "Marie Curie" avec un motif de "bic erronné"
    Quand la tâche de lecture des paiements est passée
    Et que je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Demandes rejetées" affiche 1

  Scénario: Le personnel de direction voit une demande de paiement liquidée
    Sachant que les tâches de préparation et d'envoi des paiements sont passées
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que l'ASP a liquidé le paiement de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Quand je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Paiements envoyés" affiche 1
    Et l'indicateur de demandes de paiements "Paiements échoués" n'est pas affiché

  Scénario: Le personnel de direction voit une demande de paiement rejetée à la liquidation
    Quand les tâches de préparation et d'envoi des paiements sont passées
    Et que l'ASP a accepté le dossier de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Et que l'ASP n'a pas pu liquider le paiement de "Marie Curie"
    Et que la tâche de lecture des paiements est passée
    Quand je rafraîchis la page
    Alors l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Paiements envoyés" affiche 0
    Et l'indicateur de demandes de paiements "Paiements échoués" affiche 1
