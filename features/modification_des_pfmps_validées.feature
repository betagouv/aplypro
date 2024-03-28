# language: fr
Fonctionnalité: Gestion des paiements
  Contexte:
    Sachant que l'API SYGNE renvoie 10 élèves dans une classe "A1" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"

  Scénario: une PFMP avec une requête de paiement en attente peut être modifiée
    Quand je consulte la dernière PFMP
    Alors je peux modifier le nombre de jours de la PFMP

  Scénario: une PFMP avec une requête de paiement incomplete peut être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement incomplète
    Quand je consulte la dernière PFMP
    Alors je peux modifier le nombre de jours de la PFMP

  Scénario: une PFMP avec une requête de paiement prête à l'envoi peut être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement prête à l'envoi
    Quand je consulte la dernière PFMP
    Alors je peux modifier le nombre de jours de la PFMP

  Scénario: une PFMP avec une requête de paiement envoyée ne peut pas être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement envoyée
    Quand je consulte la dernière PFMP
    Alors je ne peux pas éditer ni supprimer la PFMP

  Scénario: une PFMP avec une requête de paiement intégrée ne peut être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement intégrée
    Quand je consulte la dernière PFMP
    Alors je ne peux pas éditer ni supprimer la PFMP

  Scénario: une PFMP avec une requête de paiement rejetée peut être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement rejetée
    Quand je consulte la dernière PFMP
    Alors je peux modifier le nombre de jours de la PFMP

  Scénario: une PFMP avec une requête de paiement liquidé ne peut être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement liquidée
    Quand je consulte la dernière PFMP
    Alors je ne peux pas éditer ni supprimer la PFMP

  Scénario: une PFMP avec une requête de paiement échouée peut être modifiée
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement échouée
    Quand je consulte la dernière PFMP
    Alors je peux modifier le nombre de jours de la PFMP
