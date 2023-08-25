# language: fr

Fonctionnalité: Le personnel de direction consulte les listes
  Contexte:
    Sachant que je suis directeur de l'établissement "DINUM"
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Et que je me connecte

  Scénario: Le personnel de direction consulte le profil d'un élève
    Quand je clique sur "Voir les élèves" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil de l'élève" dans la rangée "Curie Marie"
    Alors la page est titrée "Marie Curie"
    Et le fil d'Ariane affiche "Liste des classes > Classe de 3EMEB > Marie Curie"

  Scénario: Le personnel de direction peut voir la complétion des saisies de coordonnées bancaires
    Quand je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "3EMEB"
    Et que je consulte la liste des classes
    Alors la page contient "1/"

  Scénario: Le personnel de direction peut voir les prochains paiements
    Sachant que je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "3EMEB"
    Et que je renseigne une PFMP de 3 jours pour "Marie Curie"
    Quand je consulte la liste des classes
    Alors la page contient "Il y a 1 PFMP à valider"
