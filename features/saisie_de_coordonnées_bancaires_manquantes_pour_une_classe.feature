# language: fr

Fonctionnalité: Saisie des coordonnées banquaires manquantes pour une classe
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Et qu'il y a un élève "Paul Langevin" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que je consulte la classe de "2NDEB"

  Scénario: Le personnel peut accéder à la page de création de ribs pour les élèves n'en ayant pas
    Quand je clique sur "Saisir 2 coordonnées bancaires"
    Alors la page est titrée "Saisir des coordonnées bancaires"
    Et la page contient "Curie Marie"
    Et la page contient "Langevin Paul"

  Scénario: Le personnel ne voit que les élèves n'ayant pas déjà de coordonnées bancaires
    Et que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que je rafraîchis la page
    Quand je clique sur "Saisir 1 coordonnée bancaire"
    Alors la page ne contient pas "Curie Marie"
    Et la page contient "Langevin Paul"

  Scénario: Le personnel peut saisir et sauvegarder des coordonnées bancaires pour plusieurs élèves à la fois
    Et que je clique sur "Saisir 2 coordonnées bancaires"
    Quand Je saisis les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que Je saisis les coordonées bancaires d'un tiers pour "Langevin Paul"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
    Alors je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Coordonnées Bancaires (2/2) | PFMPs (0) |
      | Curie Marie   | Saisies                     |           |
      | Langevin Paul | Saisies                     |           |

  Scénario: Le personnel peut laisser des coodonnées bancaires vides et quand même sauvegarder le reste
    Et que je clique sur "Saisir 2 coordonnées bancaires"
    Quand Je saisis les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
    Alors je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Coordonnées Bancaires (1/2) | PFMPs (0) |
      | Curie Marie   | Saisies                     |           |
      | Langevin Paul | Non saisies                 |           |

  Scénario: Le personnel saisit des coodonnées bancaires invalides et voit ses erreurs
    Et que je clique sur "Saisir 2 coordonnées bancaires"
    Quand je remplis le champ "IBAN" avec "AAA" dans les champs de "Curie Marie"
    Quand je remplis le champ "Titulaire du compte" avec "" dans les champs de "Curie Marie"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page ne contient pas "Coordonnées bancaires enregistrées avec succès"
    Et la page contient "Titulaire du compte doit être rempli(e)"
    Et la page contient "IBAN n'est pas valide"
    Et la page contient "BIC n'est pas valide"

  Scénario: Le personnel saisit des coodonnées bancaires valides et invalides et enregistre quand même les valides
    Et que je clique sur "Saisir 2 coordonnées bancaires"
    Quand Je saisis les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que je remplis le champ "IBAN" avec "AAA" dans les champs de "Langevin Paul"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "IBAN n'est pas valide"
    Et je consulte la classe de "2NDEB"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Coordonnées Bancaires (1/2) | PFMPs (0) |
      | Curie Marie   | Saisies                     |           |
      | Langevin Paul | Non saisies                 |           |

