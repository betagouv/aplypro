# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que mon établissement propose une formation "Développement" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"
    Quand je rafraîchis la page
    Et que je clique sur "Élèves"
    Et que je clique sur "Voir la classe" dans la rangée "2NDEB"
    Et que je clique sur "Voir le profil" dans la rangée "Curie Marie"

  Scénario: Le personnel de direction peut voir le nombre de PFMP réalisée
    Quand l'élève n'a réalisé aucune PFMP
    Alors la page contient "Aucune PFMP enregistrée pour le moment."

  Scénario: Le personnel de direction peut rajouter une PFMP
    Quand je renseigne une PFMP de 3 jours
    Alors la page contient "La PFMP a bien été enregistrée"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               3 | 45 € |

  Scénario: Le personnel de direction peut rajouter une PFMP pour toute la classe
    Quand je saisis une PFMP pour toute la classe "2NDEB" avec les dates "17/03/2023" et "20/03/2023"
    Alors tous les élèves ont une PFMP du "17/03/2023" au "20/03/2023"
    Et la page contient "La PFMP a bien été enregistrée"

  Scénario: Le personnel de direction est informé d'une erreur de saisie pour toute la classe
    Quand je saisis une PFMP pour toute la classe "2NDEB" avec les dates "17/03/2023" et "10/03/2023"
    Alors la page contient "doit être ultérieure à la date de début"
    Et la page ne contient pas "Schooling"

  Scénario: Le personnel de direction peut modifier une PFMP
    Quand je renseigne une PFMP de 3 jours
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "10"
    Et que je clique sur "Modifier la PFMP"
    Alors la page contient "La PFMP a bien été mise à jour"
    Et je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             |  Nombre de jours | Montant  |
      | Saisie à valider |               10 | 150 € |

  Scénario: Le personnel de direction peut valider une PFMP individuellement
    Quand je renseigne une PFMP de 3 jours
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Valider"
    Alors la page contient "La PFMP de Marie Curie a bien été validée"

  Scénario: Le personnel autorisé ne peut pas valider une PFMP individuellement
    Sachant que je me déconnecte
    Et que je me connecte en tant que personnel autorisé de l'établissement "DINUM"
    Et que je passe l'écran d'accueil
    Et que je consulte le profil de "Marie Curie" dans la classe de "2NDEB"
    Et que je renseigne une PFMP de 3 jours
    Quand je clique sur "Voir la PFMP"
    Alors la page ne contient pas "Valider"

  Scénario: Le personnel de direction peut supprimer une PFMP
    Quand je renseigne une PFMP de 4 jours
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Supprimer la PFMP"
    Et que je clique sur "Confirmer la suppression"
    Alors la page contient "La PFMP de Marie Curie a bien été supprimée"
    Et la page contient "Aucune PFMP enregistrée pour le moment"

  Scénario: Le personnel ne peut pas voir les PFMPs d'autres établissements
    Sachant que l'élève a une PFMP dans un autre établissement
    Et que je rafraîchis la page
    Alors la page contient "Aucune PFMP enregistrée pour le moment"
