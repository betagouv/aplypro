# language: fr

Fonctionnalité: Complétion des PFMPs d'une classe
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Et qu'il y a un élève "Paul Langevin" au sein de la classe "2NDEB" pour une formation "Développement"
    Et que je saisis une PFMP pour toute la classe "2NDEB" avec les dates "17/03/2025" et "17/04/2025"
    Et que je clique sur "Compléter 2 PFMPs"

  Scénario: Le personnel peut accéder à la page de complétion des PFMPs à compléter
    Alors je peux voir dans le tableau "Liste des pfmps à compléter de la classe 2NDEB"
      | Élève         | PFMP                  | Nombre de jours |
      | Curie Marie   | mars 2025 - avr. 2025 |                 |
      | Langevin Paul | mars 2025 - avr. 2025 |                 |

  Scénario: Le personnel peut saisir et enregistrer des nombre de jours pour toutes les PFMPs à compléter
    Et que je remplis le champ "Nombre de jours" dans la rangée "Curie Marie" avec "12"
    Et que je remplis le champ "Nombre de jours" dans la rangée "Langevin Paul" avec "4"
    Quand je clique sur "Enregistrer 2 PFMPs"
    Alors la page contient "Les PFMPs ont bien été modifiées"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (2)    | Décisions d'attribution (0/2) | Coordonnées Bancaires (0/2) | PFMPs (2)                              |
      | Curie Marie   |                               |                             | Saisie à valider mars 2025 - avr. 2025 |
      | Langevin Paul |                               |                             | Saisie à valider mars 2025 - avr. 2025 |

  Scénario: Le personnel est informé d'une erreur de saisie quand il complète les PFMPs d'une classe
    Et que je remplis le champ "Nombre de jours" dans la rangée "Curie Marie" avec "-12"
    Et que je remplis le champ "Nombre de jours" dans la rangée "Langevin Paul" avec "4"
    Quand je clique sur "Enregistrer 2 PFMPs"
    Alors la page contient "Nombre de jours effectués doit être supérieur à 0"
