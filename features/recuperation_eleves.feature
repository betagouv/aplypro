# language: fr

Fonctionnalité: Le personnel de direction récupère correctement les élèves
  Scénario: Le personnel de direction MENJ récupère ses élèves
    Sachant que l'API SYGNE renvoie une liste d'élèves pour l'établissement "DINUM"
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Quand je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient un compteur à "0 / 10"

  Scénario: Le personnel de direction MASA récupère ses élèves
    Sachant que l'API FREGATA renvoie une liste d'élèves pour l'établissement "DINUM"
    Et que je suis un personnel MASA directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MASA
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Quand je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient un compteur à "0 / 10"
