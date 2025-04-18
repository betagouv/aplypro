# language: fr

Fonctionnalité: Le personnel de direction consulte les listes
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et l'API SYGNE renvoie une classe "2NDEB" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je clique sur "Classes"

  Scénario: Le personnel de direction peut voir la complétion des saisies de coordonnées bancaires
    Quand je renseigne les coordonnées bancaires de l'élève "Curie Marie" de la classe "2NDEB"
    Et que je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 2NDEB  | 0 / 10                  | 1 / 10                |       |


  Scénario: Le personnel de direction ne peut pas voir la complétion des saisies de coordonnées bancaires pour un autre établissement
    Et que l'API SYGNE renvoie une classe "1EREB" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "123"
    Quand l'élève "Curie Marie" a déjà des coordonnées bancaires pour l'établissement "123"
    Et que je clique sur "Classes"
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs | Paiements |
      | 2NDEB  | 0 / 10                  | 0 / 10                |       |           |

  Scénario: Le personnel de direction peut voir la complétion des décisions d'attribution
    Et que je génère les décisions d'attribution de mon établissement
    Et que je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 2NDEB  | 10 / 10                 | 0 / 10                |       |

  Scénario: Le personnel de direction peut voir les PFMPs dans différents états
    Sachant que je consulte la classe de "2NDEB"
    Et que je renseigne et valide une PFMP de 10 jours pour "Curie Marie"
    Et que je consulte le profil de "Curie Marie" dans la classe de "2NDEB"
    Et que je renseigne une PFMP provisoire
    Et que je renseigne une PFMP de 3 jours
    Quand je consulte la liste des classes
    Alors je peux voir 1 PFMP "À compléter" pour la classe "2NDEB"
    Et je peux voir 1 PFMP "Saisies à valider" pour la classe "2NDEB"
    Et je peux voir 1 PFMP "Validées" pour la classe "2NDEB"

  Scénario: La liste des élèves d'une classe est toujours triée par ordre alphabétique nom-prénom
    Sachant qu'il y a un élève "AAA Paul" au sein de la classe "2NDEB" pour une formation "Art"
    Et qu'il y a un élève "AAB Paul" au sein de la classe "2NDEB" pour une formation "Art"
    Et qu'il y a un élève "AAB André" au sein de la classe "2NDEB" pour une formation "Art"
    Quand je clique sur "Voir la classe" dans la rangée "2NDEB"
    Alors je peux voir dans le tableau "Liste des élèves" dans cet ordre :
      | Élève     |
      | AAA Paul  |
      | AAB André |
      | AAB Paul  |
