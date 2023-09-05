# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que mon établissement propose une formation "Développement" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Quand je rafraîchis la page
    Et que je clique sur "Voir les élèves" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil de l'élève" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction peut voir le nombre de PFMP réalisée
    Quand l'élève n'a réalisé aucune PFMP
    Alors la page contient "Aucune PFMP enregistrée pour le moment."

  Scénario: Le personnel de direction peut rajouter une PFMP
    Quand je renseigne une PFMP de 3 jours pour "Marie Curie"
    Alors la page contient "La PFMP a été enregistrée avec succès"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État      | Date de début | Date de fin | Nombre de jours | Montant | Actions      |
      | Complétée | 17/03/2023    | 20/03/2023  |               3 | 45,00 € | Modifier la PFMP |

  Scénario: Le personnel de direction peut rajouter une PFMP pour toute la classe
    Quand je vais voir la classe "3EMEB"
    Et que je clique sur "Renseigner une PFMP pour toute la classe"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "20/03/2023"
    Et que je clique sur "Enregistrer"
    Alors tous les élèves ont une PFMP du "17/03/2023" au "20/03/2023"

  Scénario: Le personnel de direction peut modifier une PFMP
    Quand je renseigne une PFMP de 3 jours pour "Marie Curie"
    Et que je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "10"
    Et que je clique sur "Modifier la PFMP"
    Alors la page contient "La PFMP a bien été mise à jour"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État      | Date de début | Date de fin | Nombre de jours | Montant  | Actions          |
      | Complétée | 17/03/2023    | 20/03/2023  |              10 | 150,00 € | Modifier la PFMP |
