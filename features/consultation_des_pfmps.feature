# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que mon établissement propose une formation "Développement" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Et que je renseigne une PFMP provisoire pour "Marie Curie"

  Scénario: La PFMP est initialement dans l'onglet "Nombre de jours à compléter"
    Quand je consulte la liste des PFMPs "Nombre de jours à compléter"
    Alors je peux voir dans le tableau "Liste des PFMPs"
      | Classe          | Élève       | Date de début | Date de fin | Nombre de jours | Montant | Actions          |
      | Classe de 3EMEB | Marie Curie | 17/03/2023    | 20/03/2023  |                 |         | Modifier la PFMP |

  Scénario: La PFMP passe dans l'onglet "Complétées" lorsque je renseigne le nombre de jours
    Quand je renseigne 3 jours pour la dernière PFMP de "Marie Curie"
    Et que je consulte la liste des PFMPs "Nombre de jours à compléter"
    Alors je peux voir dans le tableau "Liste des PFMPs"
      | Classe          | Élève       | Date de début | Date de fin | Nombre de jours | Montant | Actions          |
      | Classe de 3EMEB | Marie Curie | 17/03/2023    | 20/03/2023  |               3 | 45,00 € | Modifier la PFMP |
