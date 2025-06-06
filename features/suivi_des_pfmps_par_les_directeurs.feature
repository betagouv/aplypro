# language: fr

Fonctionnalité: Suivi des demandes de paiement
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et que l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 9 jours pour "Curie Marie"

  Scénario: le personnel peut ne pas voir de paiements en échecs
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement intégrée
    Et que je clique sur "Paiements"
    Alors la page ne contient pas "Liste des paiements non-aboutis"

  Scénario: Le personnel voit la liste en accordéon des paiements non-aboutis
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement échouée
    Et que je clique sur "Paiements"
    Alors la liste des paiements non-aboutis ne contient pas l'accordéon intitulé "Bloquée"
    Et la liste des paiements non-aboutis ne contient pas l'accordéon intitulé "Demande rejetée"
    Et la liste des paiements non-aboutis contient l'accordéon intitulé "Paiement échoué"

  Scénario: Le personnel peut voir les paiements qui ont échoués et relancer une demande de paiement
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement échouée
    Et que je clique sur "Paiements"
    Alors la page contient "Liste des paiements non-aboutis"
    Et la page contient "Le paiement a été refusé par l'agence comptable :"

  Scénario: Le personnel peut voir les paiements qui ont été rejetés
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement rejetée
    Et que je clique sur "Paiements"
    Alors la page contient "Liste des paiements non-aboutis"
    Alors la page contient "La demande a été rejetée :"

  Scénario: Le personnel peut identifier les paiements qui sont actuellement bloqués
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement incomplète
    Et que je clique sur "Paiements"
    Alors la page contient "Liste des paiements non-aboutis"
    Alors la page contient "Il manque des données pour envoyer le paiement : "

  Scénario: Le personnel peut relancer une demande de paiement dans les cas de paiements préalables échoués
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement échouée
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"
    Quand je consulte la dernière PFMP
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Relancer une demande de paiement"
    Alors la page contient "Une nouvelle demande de paiement a été créée"

  Scénario: Le personnel peut relancer une demande de paiement dans les cas de paiement préalables rejetés
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement rejetée
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"
    Quand je consulte la dernière PFMP
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Relancer une demande de paiement"
    Alors la page contient "Une nouvelle demande de paiement a été créée"

  Scénario: Le personnel peut tenter de débloquer une demande de paiement et échouer si aucune des raisons de bloquage n'est addressée
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement incomplète
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"
    Quand je consulte la dernière PFMP
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Retenter la demande de paiement"
    Alors la page contient "La demande de paiement est toujours incomplète pour Curie Marie, veuillez vous référer à la liste des informations manquantes ci-dessous"

  Scénario: Le personnel peut réussir à débloquer une demande de paiement si les raisons de bloquage sont addressées
    Sachant que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement incomplète
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"
    Et que l'élève "Curie Marie" a un INE
    Et que les informations personnelles ont été récupérées pour l'élève "Curie Marie"
    Quand je consulte la dernière PFMP
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Retenter la demande de paiement"
    Alors la page contient "La demande de paiement a été relancée avec succès pour Curie Marie"
