# language: fr


Fonctionnalité: Les anciens élèves ne sont pas inclus dans l'interface
  Contexte:
    Sachant que l'API SYGNE renvoie 10 élèves en "1MELEC" dont l'INE "test" pour l'établissement "DINUM"
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Sachant que l'élève de SYGNE avec l'INE "test" a quitté l'établissement "DINUM"

  Scénario: Les anciens élèves ne sont pas affichés dans le compteur des décisions d'attribution
    Quand je rafraîchis la page
    Alors le panneau "Décisions d'attribution" contient "0 / 9"

  Scénario: Les anciens élèves ne sont pas affichés dans le compteur des saisies banciares
    Quand je rafraîchis la page
    Alors le panneau "Coordonnées bancaires" contient "0 / 9"

  Scénario: Les anciens élèves ne sont pas affichés dans les listings de classe
    Quand je consulte la liste des classes
    Alors le tableau "Liste des classes" contient
      | Classe | Décisions d'attribution | Coordonnées bancaires | PFMPs |
      | 1MELEC |                   0 / 9 |                 0 / 9 |       |
