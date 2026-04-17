# language: fr

Fonctionnalité: Rectification de PFMP (gestion d'indus)
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 9 jours pour "Curie Marie"
    Et que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement liquidée
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"
    Et que je consulte la dernière PFMP

  Scénario: Le directeur peut rectifier une PFMP payée
    Quand je clique sur "Gérer un indu"
    Et que je remplis "Nouveau nombre de jours travaillés" avec "5"
    Et que je coche la case de responsable légal
    Et que je clique sur "Confirmer la rectification"
    Alors la page contient "La PFMP a bien été corrigée et relancée pour un nouveau paiement"

  Scénario: Une erreur est affichée si les dates de rectification dépassent la période de scolarité
    Sachant que la scolarité de "Curie Marie" se termine avant la fin de la PFMP
    Quand je clique sur "Gérer un indu"
    Et que je coche la case de responsable légal
    Et que je clique sur "Confirmer la rectification"
    Alors la page contient "Les dates de la PFMP ne sont pas comprises dans la période de scolarité"
    Et la page est titrée "Rectification de la PFMP"

  Scénario: Une erreur est affichée si la rectification génèrerait un paiement négatif
    Sachant que le montant liquidé de la dernière PFMP de "Curie Marie" est de 90 euros
    Quand je clique sur "Gérer un indu"
    Et que je remplis "Nouveau nombre de jours travaillés" avec "2"
    Et que je coche la case de responsable légal
    Et que je clique sur "Confirmer la rectification"
    Alors la page contient "Cette rectification génèrerait un ordre de reversement"
    Et la page est titrée "Rectification de la PFMP"
