# language: fr
Fonctionnalité: Gestion des paiements
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je renseigne et valide une PFMP de 3 jours

  Scénario: Le personnel de direction peut voir un paiement planifié
    Alors je peux voir une demande de paiement "En attente" de 30 euros

  Scénario: Le personnel de direction peut voir un paiement bloqué
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement incomplète
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "Bloquée" de 30 euros

  Scénario: Le personnel de direction peut voir un paiment prêt pour l'ASP
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement prête à l'envoi
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En attente" de 30 euros
    Et la page contient "La demande de paiement a toutes les informations nécessaires."

  Scénario: Le personnel de direction peut voir un paiement envoyé à l'ASP
    Sachant que la dernière PFMP de "Marie Curie" en classe de "A1" a une requête de paiement envoyée
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En traitement" de 30 euros
