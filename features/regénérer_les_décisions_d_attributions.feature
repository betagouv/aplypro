# language: fr

Fonctionnalité: Le personnel de direction peut éditer les décisions d'attribution
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Marie Curie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil

  Scénario: Le personnel de direction ne peut pas rééditer les décisions d'attribution si il n'y en a aucune
    Et que le panneau "Décisions d'attribution" contient un compteur à 0 sur 10
    Alors le panneau "Décisions d'attribution" ne contient pas "Rééditer les décisions d'attribution"

  Scénario: Seul le personnel de direction peut voir le bouton pour rééditer les décisions d'attribution
    Et que je suis un personnel MENJ de l'établissement "DINUM"
    Et que je me déconnecte
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors le panneau "Décisions d'attribution" ne contient pas "Rééditer les décisions d'attribution"

  Scénario: Le personnel de direction peut voir un bouton pour régénérer les décisions d'attribution
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et que je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient "Rééditer les décisions d'attribution"

  Scénario: Le personnel de direction peut rééditer les décisions d'attribution
    Et que je suis responsable légal et que je génère les décisions d'attribution manquantes
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et que je me rends sur la page d'accueil
    Et que le panneau "Décisions d'attribution" contient "Rééditer les décisions d'attribution"
    Et que je clique sur "Rééditer les décisions d'attribution"
    Et que la génération des décisions d'attribution est complètement finie
    Alors le panneau "Décisions d'attribution" contient "Télécharger 10 décisions d'attribution"