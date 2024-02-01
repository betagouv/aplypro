# language: fr

Fonctionnalité: Le personnel de direction consulte les listes
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que je clique sur "Élèves"
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que je rafraîchis la page

  Scénario: Le personnel de direction consulte le profil d'un élève
    Quand je clique sur "Voir la classe" dans la rangée "2NDEB"
    Et que je clique sur "Voir le profil" dans la rangée "Curie Marie"
    Alors la page est titrée "Marie Curie"
    Et le fil d'Ariane affiche "Liste des classes > Classe de 2NDEB > Marie Curie"

  Scénario: Le personnel de direction peut voir la complétion des saisies de coordonnées bancaires
    Quand je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 2NDEB  |                   0 / 1 |                 1 / 1 |       |

  Scénario: Le personnel de direction peut voir la complétion des décisions d'attribution
    Quand je génère les décisions d'attribution de mon établissement
    Et que je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 2NDEB  |                   1 / 1 |                 0 / 1 |       |

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
    Et que il y a un élève "Paul Allègre" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que il y a un élève "André Allègre" au sein de la classe "2NDEB" pour une formation "Développement"
    Quand je clique sur "Voir la classe" dans la rangée "2NDEB"
    Alors je peux voir dans le tableau "Liste des élèves" dans cet ordre :
      | Élève         |
      | Allègre André |
      | Allègre Paul  |
      | Curie Marie   |
