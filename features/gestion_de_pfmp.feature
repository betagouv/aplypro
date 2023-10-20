# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que mon établissement propose une formation "Développement" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Quand je rafraîchis la page
    Et que je clique sur "Voir la classe" dans la rangée "3EMEB"
    Et que je clique sur "Voir le profil" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction peut voir le nombre de PFMP réalisée
    Quand l'élève n'a réalisé aucune PFMP
    Alors la page contient "Aucune PFMP enregistrée pour le moment."

  Scénario: Le personnel de direction peut rajouter une PFMP
    Quand je renseigne une PFMP de 3 jours pour "Marie Curie"
    Alors la page contient "La PFMP a bien été enregistrée"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               3 | 45,00 € |

  Scénario: Le personnel de direction peut rajouter une PFMP pour toute la classe
    Quand je vais voir la classe "3EMEB"
    Et que je clique sur "Saisir une PFMP pour toute la classe"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "20/03/2023"
    Et que je clique sur "Enregistrer"
    Alors tous les élèves ont une PFMP du "17/03/2023" au "20/03/2023"

  Scénario: Le personnel de direction est informé d'une erreur de saisie pour toute la classe
    Étant donné que je vais voir la classe "3EMEB"
    Et que je clique sur "Saisir une PFMP pour toute la classe"
    Et que je remplis "Date de début" avec "17/03/2023"
    Et que je remplis "Date de fin" avec "10/03/2023"
    Quand je clique sur "Enregistrer"
    Alors la page contient "doit être ultérieure à la date de début"
    Et la page ne contient pas "Schooling"

  Scénario: Le personnel de direction peut modifier une PFMP
    Quand je renseigne une PFMP de 3 jours pour "Marie Curie"
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "10"
    Et que je clique sur "Modifier la PFMP"
    Alors la page contient "La PFMP a bien été mise à jour"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             |  Nombre de jours | Montant
      | Saisie à valider |               10 | 150,00 €

  Scénario: Le personnel de direction peut valider une PFMP individuellement
    Quand je renseigne une PFMP de 3 jours pour "Marie Curie"
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Valider"
    Alors la page contient "La PFMP de Marie Curie a bien été validée"

  Scénario: Le personnel autorisé ne peut pas valider une PFMP individuellement
    Sachant que je me connecte en tant que personnel autorisé de l'établissement
    Et que je passe l'écran d'accueil
    Et que je renseigne une PFMP de 3 jours pour "Marie Curie"
    Quand je clique sur "Voir la PFMP"
    Alors la page ne contient pas "Valider"

  Scénario: Le personnel de direction peut supprimer une PFMP
    Quand je renseigne une PFMP de 4 jours pour "Marie Curie"
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Supprimer la PFMP"
    Et que je clique sur "Confirmer la suppression"
    Alors la page contient "La PFMP de Marie Curie a bien été supprimée"
    Et la page contient "Aucune PFMP enregistrée pour le moment"
