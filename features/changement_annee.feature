# language: fr

Fonctionnalité: Accueil d'un personnel de direction sur l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil

  Scénario: Le personnel de direction voit l'année scolaire par défaut
    Alors la page contient "Année scolaire 2025-2026"
    Et que le bandeau informatif contient "2025-2026"

  Scénario: Le personnel de direction change d'année scolaire
    Quand je consulte l'année scolaire "2023-2024"
    Alors la page contient "Année scolaire 2023-2024"
    Et le bandeau informatif contient "2023-2024"

  Scénario: Le personnel de direction change d'année scolaire et conserve l'année scolaire sélectionnée sur une page n'en ayant pas besoin
    Quand je consulte l'année scolaire "2023-2024"
    Et que je clique sur "F.A.Q."
    Alors le bandeau informatif contient "2023-2024"

  Scénario: Le personnel de direction consulte une année scolaire sans élèves
    Quand je consulte l'année scolaire "2023-2024"
    Alors la page contient "Aucun élève récupéré au cours de l'année scolaire sélectionnée."

  Scénario: Le personnel de direction ne voit pas les décisions d'attribution d'une autre année scolaire
    Lorsque j'ai une classe "1MELEC" de 9 élèves pour l'établissement "DINUM" lors de l'année 2023
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Quand je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient "10 / 10"
    Et que je clique sur le premier "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Alors le panneau "Décisions d'attribution" contient "0 / 9"

  Scénario: Le personnel de direction ne voit pas les classes d'une autre année scolaire
    Lorsque j'ai une classe "1MELEC" de 9 élèves pour l'établissement "DINUM" lors de l'année 2023
    Et que je clique sur "Classes"
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 1MELEC | 0 / 10                  | 0 / 10                |       |
    Et que je clique sur le premier "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Et que je clique sur "Classes"
    Alors je peux voir dans le tableau "Liste des classes"
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 1MELEC | 0 / 9                   | 0 / 9                 |       |

  Scénario: Le personnel de direction ne voit pas les paiements d'une autre année scolaire
    Lorsque j'ai une classe "1MELEC" de 9 élèves pour l'établissement "DINUM" lors de l'année 2023
    Et que je consulte le profil de "Curie Marie" dans la classe de "1MELEC"
    Et que je renseigne une PFMP de 9 jours
    Et que la dernière PFMP de "Curie Marie" est validable
    Et que je clique sur "Paiements"
    Alors la page ne contient pas "Il n'y a aucune PFMP à valider pour l'instant."
    Et que je clique sur le premier "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Et que je clique sur "Paiements"
    Alors la page contient "Il n'y a aucune PFMP à valider pour l'instant."

  Scénario: Le personnel de direction ne peut pas rééditer les décisions d'attribution d'une autre année scolaire
    Lorsque j'ai une classe "1MELEC" de 9 élèves pour l'établissement "DINUM" lors de l'année 2023
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Quand je me rends sur la page d'accueil
    Alors la page contient "Rééditer les décisions d'attribution"
    Et que je clique sur le premier "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Alors la page ne contient pas "Rééditer les décisions d'attribution"
