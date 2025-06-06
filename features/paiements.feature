# language: fr
Fonctionnalité: Gestion des paiements
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 9 jours pour "Curie Marie"
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"

  Scénario: une PFMP avec une requête de paiement en attente peut être modifiée
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En attente" de 90 euros
    Et je peux changer le nombre de jours de la PFMP à 8

  Scénario: une PFMP avec une requête de paiement incomplete peut être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement incomplète
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "Bloquée" de 90 euros
    Et je peux changer le nombre de jours de la PFMP à 8

  Scénario: une PFMP avec une requête de paiement prête à l'envoi ne peut pas être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement prête à l'envoi
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En attente" de 90 euros
    Et je ne peux pas éditer ni supprimer la PFMP

  Scénario: une PFMP avec une requête de paiement envoyée ne peut pas être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement envoyée
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En traitement" de 90 euros
    Et je ne peux pas éditer ni supprimer la PFMP

  Scénario: une PFMP avec une requête de paiement intégrée ne peut être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement intégrée
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "En traitement" de 90 euros
    Et je ne peux pas éditer ni supprimer la PFMP

  Scénario: une PFMP avec une requête de paiement rejetée peut être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement rejetée
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "rejetée" de 90 euros
    Et la page contient "La demande a été rejetée : Un problème est survenu, merci de prendre contact avec votre support technique."
    Et je peux changer le nombre de jours de la PFMP à 8

  Scénario: une PFMP avec une requête de paiement liquidée ne peut être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement liquidée
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "envoyé" de 90 euros
    Et je ne peux pas éditer ni supprimer la PFMP
    Et la page contient "Gérer un indu"

  Scénario: une PFMP avec une requête de paiement échouée peut être modifiée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement échouée
    Quand je consulte la dernière PFMP
    Alors je peux voir une demande de paiement "échoué" de 90 euros
    Et je peux changer le nombre de jours de la PFMP à 8

  Scénario: Seule la dernière demande de paiement d'une PFMP est affichée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement rejetée
    Et que je consulte la liste des classes
    Alors la page contient "Bloquées"
    Quand je consulte le profil de "Curie Marie" dans la classe de "A1"
    Quand je consulte la dernière PFMP
    Et que je coche la case de responsable légal
    Et que je clique sur "Relancer une demande de paiement"
    Lorsque je consulte la liste des classes
    Alors la page contient "En attente"
    Et la page ne contient pas "Bloquées"
