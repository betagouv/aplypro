# language: fr

Fonctionnalité: Le personnel de direction peut éditer les décisions d'attribution
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Marie Curie" pour l'établissement "DINUM"
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
    Quand l'élève "Marie Curie" a une scolarité fermée
    Et je consulte la classe de "1MELEC"
    Lorsque je clique sur "Abroger"
    Alors la page contient "Êtes-vous certain(e) de vouloir abroger cette décision d'attribution ?"
    Lorsque je clique sur "Confirmer l'abrogation"
    Alors la page contient "Télécharger la décision d'abrogation"
