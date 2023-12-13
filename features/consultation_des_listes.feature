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
    Alors la page contient "1/"

  Scénario: La liste des élèves d'une classe est toujours triée par ordre alphabétique nom-prénom
    Et que il y a un élève "Paul Allègre" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que il y a un élève "André Allègre" au sein de la classe "2NDEB" pour une formation "Développement"
    Quand je clique sur "Voir la classe" dans la rangée "2NDEB"
    Alors je peux voir dans le tableau "Liste des élèves" dans cet ordre :
      | Élève         |
      | Allègre André |
      | Allègre Paul  |
      | Curie Marie   |