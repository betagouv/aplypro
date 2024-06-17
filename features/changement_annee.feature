# language: fr

Fonctionnalité: Accueil d'un personnel de direction sur l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil

  Scénario: Le personnel de direction voit l'année scolaire par défaut
    Alors la page contient "Année scolaire 2024-2025"
    Et que le bandeau informatif contient "2024-2025"

  Scénario: Le personnel de direction change d'année scolaire
    Quand je clique sur "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Alors la page contient "Année scolaire 2023-2024"
    Et le bandeau informatif contient "2023-2024"

  Scénario: Le personnel de direction consulte une année scolaire sans élèves
    Quand je clique sur "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Alors la page contient "Aucun élève récupéré au cours de l'année scolaire 2023-2024"

  Scénario: Le personnel de direction ne voit pas les décisions d'attribution d'une autre année scolaire
    Lorsque j'ai une classe "1MELEC" de 9 élèves pour l'établissement "DINUM" lors de l'année 2023
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Quand je me rends sur la page d'accueil
    Et que le panneau "Décisions d'attribution" contient "10 / 10"
    Et que je clique sur "Changer d'année scolaire"
    Et que je clique sur "2023-2024"
    Alors le panneau "Décisions d'attribution" contient "0 / 9"