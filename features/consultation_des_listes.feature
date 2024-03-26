# language: fr

Fonctionnalité: Le personnel de direction consulte les listes
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 10 euros par jour et plafonnée à 100 euros par an
    Et l'API SYGNE renvoie une classe "2NDEB" de 10 élèves en formation "Art" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je clique sur "Élèves"

  Scénario: Le personnel de direction peut voir la complétion des saisies de coordonnées bancaires
    Quand je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 2NDEB  | 0 / 10                  | 1 / 10                |       |

  Scénario: Le personnel de direction peut voir la complétion des décisions d'attribution
    Quand l'API SYGNE peut fournir les informations complètes des étudiants
    Et que je génère les décisions d'attribution de mon établissement
    Et que je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 2NDEB  | 10 / 10                 | 0 / 10                |       |

  Scénario: Le personnel de direction peut voir les PFMPs dans différents états
    Sachant que je consulte le profil de "Marie Curie" dans la classe de "2NDEB"
    Et que je renseigne une PFMP provisoire
    Et que je renseigne une PFMP de 3 jours
    Et que je renseigne et valide une PFMP de 10 jours
    Quand je consulte la liste des classes
    Alors je peux voir 1 PFMP "À compléter" pour la classe "2NDEB"
    Et je peux voir 1 PFMP "Saisies à valider" pour la classe "2NDEB"
    Et je peux voir 1 PFMP "Validées" pour la classe "2NDEB"

  Scénario: La liste des élèves d'une classe est toujours triée par ordre alphabétique nom-prénom
    Sachant qu'il y a un élève "Paul AAA" au sein de la classe "2NDEB" pour une formation "Art"
    Et qu'il y a un élève "Paul AAB" au sein de la classe "2NDEB" pour une formation "Art"
    Et qu'il y a un élève "André AAB" au sein de la classe "2NDEB" pour une formation "Art"
    Quand je clique sur "Voir la classe" dans la rangée "2NDEB"
    Alors je peux voir dans le tableau "Liste des élèves" dans cet ordre :
      | Élève     |
      | AAA Paul  |
      | AAB André |
      | AAB Paul  |
