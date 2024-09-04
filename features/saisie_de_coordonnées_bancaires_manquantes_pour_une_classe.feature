# language: fr

Fonctionnalité: Saisie des coordonnées banquaires manquantes pour une classe
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Et qu'il y a un élève "Paul Langevin" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que je consulte la classe de "2NDEB"
    Et je clique sur "Saisir 2 coordonnées bancaires"

  Scénario: Le personnel ne voit que les élèves sans coordonnées bancaires
    Sachant que l'élève "Marie Curie" a déjà des coordonnées bancaires
    Et que je rafraîchis la page
    Alors la page ne contient pas "Curie Marie"
    Et la page contient "Langevin Paul"

  Scénario: Le personnel peut saisir et sauvegarder des coordonnées bancaires pour plusieurs élèves à la fois
    Sachant que je saisis en masse les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que je saisis en masse les coordonées bancaires d'un tiers pour "Langevin Paul"
    Quand je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Décisions d'attribution (0/2) | Coordonnées Bancaires (2/2) | PFMPs (0) |
      | Curie Marie   |                               | Saisies                     |           |
      | Langevin Paul |                               | Saisies                     |           |

  Scénario: Le personnel peut saisir et sauvegarder des coordonnées bancaires pour plusieurs élèves à la fois
    Sachant que je saisis en masse les coordonées bancaires d'une personne morale pour "Curie Marie"
    Et que je saisis en masse les coordonées bancaires d'une personne morale pour "Langevin Paul"
    Quand je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Décisions d'attribution (0/2) | Coordonnées Bancaires (2/2) | PFMPs (0) |
      | Curie Marie   |                               | Saisies                     |           |
      | Langevin Paul |                               | Saisies                     |           |

  Scénario: Le personnel peut laisser des coordonnées bancaires vides et quand même sauvegarder le reste
    Quand je saisis en masse les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Décisions d'attribution (0/2) | Coordonnées Bancaires (1/2) | PFMPs (0) |
      | Curie Marie   |                               | Saisies                     |           |
      | Langevin Paul |                               | Non saisies                 |           |

  Scénario: Le personnel saisit des coordonnées bancaires invalides et voit ses erreurs
    Quand je remplis le champ "IBAN" avec "AAA" dans les champs de "Curie Marie"
    Et que je remplis le champ "Titulaire du compte" avec "" dans les champs de "Curie Marie"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page ne contient pas "Coordonnées bancaires enregistrées avec succès"
    Et la page contient "Titulaire du compte doit être rempli(e)"
    Et la page contient "IBAN n'est pas valide"
    Et la page contient "BIC n'est pas valide"

  Scénario: Le personnel saisit des coordonnées bancaires valides et invalides et enregistre quand même les valides
    Quand je saisis en masse les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que je remplis le champ "IBAN" avec "AAA" dans les champs de "Langevin Paul"
    Et que je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "IBAN n'est pas valide"
    Et je consulte la classe de "2NDEB"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Décisions d'attribution (0/2) | Coordonnées Bancaires (1/2) | PFMPs (0) |
      | Curie Marie   |                               | Saisies                     |           |
      | Langevin Paul |                               | Non saisies                 |           |

  Scénario: Le personnel peut saisir des coordonnées bancaires pour une classe même si un élève a d'autres scolarités dans d'autres classes
    Sachant que l'élève "Marie" "Curie" a une ancienne scolarité dans un autre établissement
    Et que je saisis en masse les coordonées bancaires d'un tiers pour "Curie Marie"
    Et que je saisis en masse les coordonées bancaires d'un tiers pour "Langevin Paul"
    Quand je clique sur "Enregistrer les coordonnées bancaires saisies"
    Alors la page contient "Coordonnées bancaires enregistrées avec succès"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Décisions d'attribution (0/2) | Coordonnées Bancaires (2/2) | PFMPs (0) |
      | Curie Marie   |                               | Saisies                     |           |
      | Langevin Paul |                               | Saisies                     |           |
