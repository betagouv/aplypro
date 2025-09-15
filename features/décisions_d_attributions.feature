# language: fr

Fonctionnalité: Le personnel de direction peut éditer les décisions d'attribution
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil

  Scénario: Le personnel de direction est invité à lancer les décisions d'attribution la première fois
    Quand je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient un compteur à 0 sur 10
    Et le panneau "Décisions d'attribution" contient "Éditer 10 décisions d'attribution manquantes"

  Scénario: Le personnel de direction peut lancer l'édition des décisions d'attribution
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que toutes les tâches de fond sont terminées
    Quand je me rends sur la page d'accueil
    Alors la page contient "Édition des décisions d'attribution en cours"

  Scénario: Le personnel peut télécharger l'ensemble des décisions d'attribution
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Quand je me rends sur la page d'accueil
    Alors la page contient "Télécharger 10 décisions d'attribution"
    Et le panneau "Décisions d'attribution" contient "10 / 10"

  Scénario: Le personnel peut télécharger ou générer les décisions d'attribution manquantes
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et que l'API SYGNE renvoie 5 nouveaux élèves pour l'établissement "DINUM"
    Et que les élèves de l'établissement "DINUM" sont rafraîchis
    Quand je me rends sur la page d'accueil
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et que je rafraîchis la page
    Alors la page contient "Télécharger 15 décisions d'attribution"

  Scénario: Le personnel qui ne coche pas la case de responsable légal ne peut pas générer les décisions d'attribution
    Lorsque je décoche la case de responsable légal
    Et que je clique sur "Éditer 10 décisions d'attribution manquantes"
    Alors la page contient "Vous devez être chef d'établissement"
    Et le panneau "Décisions d'attribution" contient "0 / 10"

  Scénario: Le personnel peut voir les décisions d'attributions comptées dans la liste des élèves d'une classe et abroger certaines attributions
    Quand je consulte la classe de "1MELEC"
    Et je peux voir dans le tableau "Liste des élèves"
      | Élèves (10) | Décisions d'attribution (0/10) | Coordonnées Bancaires (0/10) | PFMPs (0) |
      |             | Manquante                      |                              |           |
    Et que je me rends sur la page d'accueil
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et je consulte la classe de "1MELEC"
    Alors je peux voir dans le tableau "Liste des élèves"
      | Élèves (10) | Décisions d'attribution (10/10) | Coordonnées Bancaires (0/10) | PFMPs (0) |
      |             | Éditée                          |                              |           |
    Quand l'élève "Curie Marie" a une scolarité fermée
    Et que l'élève "Curie Marie" a une scolarité plus récente pour l'année scolaire 2024
    Et je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Lorsque je clique sur "Abroger la décision d'attribution"
    Alors la page contient "Êtes-vous certain(e) de vouloir abroger cette décision d'attribution ?"
    Lorsque je clique sur "Confirmer l'abrogation"
    Alors la page contient "Télécharger l'abrogation"

  Scénario: Le personnel ne peut pas reporter une décision d'attribution pour une scolarité active
    Quand l'élève "Curie Marie" a une date de début et une date de fin de scolarité sur l'année scolaire courante
    Et que l'élève "Curie Marie" a une décision d'attribution
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Alors la page contient un bouton "Autoriser un report" désactivé

  Scénario: Le personnel peut reporter une décision d'attribution
    Quand l'élève "Curie Marie" a une date de début et une date de fin de scolarité sur une année scolaire passée
    Et que l'élève "Curie Marie" a une décision d'attribution
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Quand je clique sur "Autoriser un report"
    Alors la page contient "Date de report"
    Quand je remplis "Date de report" avec "#{Date.parse('#{SchoolYear.current.end_year}-12-31')}"
    Et que je coche la case de responsable légal
    Et que je clique sur "Confirmer l'ajout du report"
    Alors la page contient "La décision d'attribution de Curie Marie a bien été prolongée"

  Scénario: Le personnel peut annuler la saisie d'un report de décision d'attribution
    Quand l'élève "Curie Marie" a une date de début et une date de fin de scolarité sur une année scolaire passée
    Et que l'élève "Curie Marie" a une décision d'attribution
    Et que l'élève "Curie Marie" a un report de décision d'attribution
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Quand je clique sur "Annuler le report"
    Alors la page contient "Êtes-vous certain(e) de vouloir supprimer le report de cette décision d'attribution ?"
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Confirmer la suppression du report"
    Alors la page contient "Le report de la décision d'attribution de Curie Marie a bien été supprimé"

  Scénario: Le personnel peut modifier la saisie d'un report de décision d'attribution si une pfmp est saisie
    Quand l'élève "Curie Marie" a une date de début et une date de fin de scolarité sur une année scolaire passée
    Et que l'élève "Curie Marie" a une décision d'attribution
    Et que l'élève "Curie Marie" a un report de décision d'attribution
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Et que je renseigne une PFMP provisoire dans la période de report pour l'élève "Curie Marie"
    Quand je clique sur "Modifier le report"
    Alors la page contient "Êtes-vous certain(e) de vouloir modifier le report de cette décision d'attribution ?"
    Et que je coche la case de responsable légal
    Lorsque je clique sur "Confirmer la modification du report"
    Alors la page contient "La décision d'attribution de Curie Marie a bien été prolongée"

  Scénario: Le personnel ne peut pas révoquer une décision d'attribution
    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Alors la page ne contient pas "Télécharger la décision de retrait"
    Et la page ne contient pas "Révoquer la décision d'attribution"

#  Scénario: Le personnel peut révoquer une décision d'attribution
#    Lorsque je suis responsable légal et que je génère les décisions d'attribution manquantes
#    Et que la génération des décisions d'attribution manquantes est complètement finie
#    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
#    Alors la page ne contient pas "Télécharger la décision de retrait"
#    Quand je clique sur "Révoquer la décision d'attribution"
#    Et que je coche la case de responsable légal
#    Et que je clique sur "Confirmer la révocation"
#    Alors la page contient "La décision d'attribution de Curie Marie a bien été retirée"
#    Et la page contient un bouton "Révoquer la décision d'attribution" désactivé
#    Et la page contient "Télécharger la décision de retrait"
#    Quand je consulte la classe de "1MELEC"
#    Alors je peux voir dans le tableau "Élèves masqués manuellement de la classe"
#      | Élèves (1)    | Réintégration de l'élève dans la classe      |
#      | Curie Marie   | Réintégrer Curie Marie dans la classe 1MELEC |

  Scénario: Seul le chef d'établissement a accès à certaines actions
    Sachant que l'élève "Curie Marie" a une date de début et une date de fin de scolarité sur une année scolaire passée
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Sachant que je me déconnecte
    Et que je me connecte en tant que personnel autorisé de l'établissement "DINUM"
    Et que je passe l'écran d'accueil
    Quand je consulte l'année scolaire "2022-2023"
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Alors la page contient un bouton "Autoriser un report" désactivé

  Scénario: Le personnel peut générer une décision d'attribution d'attribution individuelle
    Lorsque je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Et que je clique sur "Éditer la décision d'attribution manquante"
    Alors la page ne contient pas "Éditer la décision d'attribution manquante"
    Alors la page contient "Édition de la décision d'attribution en cours"
    Quand la génération des décisions d'attribution manquantes est complètement finie
    Et que je rafraîchis la page
    Alors la page ne contient pas "Édition de la décision d'attribution en cours"
