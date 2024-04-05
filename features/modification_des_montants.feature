# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Marie Curie" dans la classe de "A1"

  Scénario: La modification des nombres de jours peut déclencher un recalcul des montants
    Sachant que je renseigne une PFMP de 5 jours
    Sachant que je renseigne une PFMP de 6 jours
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               5 | 75 €    |
      | Saisie à valider |               6|  90 €   |
    Et que je renseigne 12 jours pour la dernière PFMP de "Marie Curie" dans la classe de "A1"
    Quand je consulte le profil de "Marie Curie" dans la classe de "A1"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               5 | 75 €    |
      | Saisie à valider |               12| 125 €   |

