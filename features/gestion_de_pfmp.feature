# language: fr

Fonctionnalité: Le personnel de direction édite les PFMPs
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que mon établissement propose une formation "Art" rémunérée à 15 euros par jour et plafonnée à 200 euros par an
    Et l'API SYGNE renvoie une classe "A1" de 10 élèves en formation "Art" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"

  Scénario: Le personnel de direction peut ajouter une PFMP quand l'élève n'en a pas encore
    Alors la section pour la classe "A1" contient "Aucune PFMP enregistrée pour le moment"
    Et la section pour la classe "A1" contient "Ajouter une PFMP"

  Scénario: Le personnel de direction peut ajouter une PFMP et la modifier
    Sachant que je renseigne une PFMP de 3 jours
    Et que la page contient "La PFMP a bien été enregistrée"
    Quand la section pour la classe "A1" contient le tableau "Liste des PFMPs de l'élève"
      | État             | Nombre de jours | Montant |
      | Saisie à valider |               3 | 45 € |
    Et la section pour la classe "A1" contient un lien sur "Voir la PFMP"

  Scénario: Le personnel peut voir les PFMPs d'autres établissements et ne peut pas les modifier
    Sachant que l'élève "Curie Marie" a une PFMP dans la classe "A2" dans un autre établissement
    Et que je rafraîchis la page
    Alors la section pour la classe "A2" ne contient pas de bouton "Ajouter une PFMP"
    Et la section pour la classe "A2" ne contient pas de lien sur "Voir la PFMP"

  Scénario: Le personnel de direction peut ajouter une PFMP pour toute la classe
    Quand je saisis une PFMP pour toute la classe "A1" avec les dates "17/03/2025" et "20/03/2025"
    Alors la page contient "Compléter 10 PFMP"

  Scénario: Le personnel de direction est informé d'une erreur de saisie pour toute la classe
    Quand je saisis une PFMP pour toute la classe "A1" avec les dates "17/03/2025" et "10/03/2025"
    Alors la page contient "La date de fin doit être ultérieure à la date de début"
    Et la page ne contient pas "Compléter 10 PFMP"

  Scénario: Le personnel de direction peut modifier une PFMP
    Sachant que je renseigne une PFMP de 13 jours
    Et que je clique sur "Voir la PFMP"
    Et que je clique sur "Modifier la PFMP"
    Et que je remplis "Nombre de jours" avec "10"
    Et que je clique sur "Modifier la PFMP"
    Et la page contient "La PFMP a bien été mise à jour"
    Quand je consulte le profil de "Curie Marie" dans la classe de "A1"
    Alors je peux voir dans le tableau "Liste des PFMPs de l'élève"
      | État             |  Nombre de jours | Montant  |
      | Saisie à valider |               10 | 150 € |

  Scénario: Le personnel de direction peut valider une PFMP individuellement
    Quand je renseigne une PFMP de 3 jours
    Et que je clique sur "Voir la PFMP"
    Alors la page contient un bouton "Valider" désactivé
    Sachant que la dernière PFMP de "Curie Marie" est validable
    Et que je rafraîchis la page
    Et que je coche la case de responsable légal
    Et que je clique sur "Valider"
    Alors la page contient "La PFMP de Curie Marie a bien été validée"

  Scénario: Le personnel autorisé ne peut pas valider une PFMP individuellement
    Sachant que je me déconnecte
    Et que je me connecte en tant que personnel autorisé de l'établissement "DINUM"
    Et que je passe l'écran d'accueil
    Et que je consulte le profil de "Curie Marie" dans la classe de "A1"
    Et que je renseigne une PFMP de 3 jours
    Quand je clique sur "Voir la PFMP"
    Alors la page ne contient pas "Valider"

  Scénario: Les PFMPs archivées et les requêtes de paiement associées ne sont plus affichées
    Sachant que je consulte la classe de "A1"
    Et que je renseigne et valide une PFMP de 9 jours pour "Curie Marie"
    Et que la dernière PFMP de "Curie Marie" en classe de "A1" a une requête de paiement rejetée
    Quand je me rends sur la page d'accueil
    Alors l'indicateur de PFMP "Validées" affiche 1
    Et l'indicateur de demandes de paiements "Demandes rejetées" affiche 1
    Quand je consulte le profil de "Curie Marie" dans la classe de "A1"
    Et que je consulte la dernière PFMP
    Et que je clique sur "Supprimer la PFMP"
    Et que je clique sur "Confirmer la suppression"
    Alors la page contient "La PFMP de Curie Marie a bien été supprimée"
    Et la page contient "Aucune PFMP enregistrée pour le moment"
    Quand je consulte la liste des classes
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs | Paiements |
      | A1     | 10 / 10                 | 1 / 10                |       |           |
    Quand je consulte la classe "A1"
    Alors la page contient "PFMPs et Paiements (0)"
    Quand je me rends sur la page d'accueil
    Alors l'indicateur de PFMP "Validées" affiche 0
    Et la page ne contient pas "Demandes rejetées"
