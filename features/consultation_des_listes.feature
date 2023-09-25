# language: fr

Fonctionnalité: Le personnel de direction consulte les listes
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Et que je rafraîchis la page

  Scénario: Le personnel de direction consulte le profil d'un élève
    Quand je clique sur "Voir la classe" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil" dans la rangée "Curie Marie"
    Alors la page est titrée "Marie Curie"
    Et le fil d'Ariane affiche "Liste des classes > Classe de 3EMEB > Marie Curie"

  Scénario: Le personnel de direction peut voir la complétion des saisies de coordonnées bancaires
    Quand je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "3EMEB"
    Et que je consulte la liste des classes
    Alors la page contient "1/"
