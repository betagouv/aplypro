# language: fr

Fonctionnalité: Le personnel de direction peut éditer les décisions d'attribution
  Contexte:
    Sachant que l'API SYGNE renvoie 10 élèves en "1MELEC" dont l'INE "test" pour l'établissement "DINUM"
    Et que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Et que je passe l'écran d'accueil

  Scénario: Le personnel de direction est invité à lancer les décisions d'attribution la première fois
    Quand je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient un compteur à 0 sur 10
    Et le panneau "Décisions d'attribution" contient "Éditer les décisions d'attribution"

  Scénario: Le personnel de direction peut lancer l'édition des décisions d'attribution
    Lorsque je clique sur "Éditer les décisions d'attribution"
    Et que toutes les tâches de fond sont terminées
    Quand je me rends sur la page d'accueil
    Alors la page contient "Édition des décisions d'attribution en cours"

  Scénario: Le personnel peut télécharger l'ensemble des décisions d'attribution
    Lorsque je clique sur "Éditer les décisions d'attribution"
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Quand je me rends sur la page d'accueil
    Alors la page contient "Télécharger l'ensemble des décisions d'attribution"
    Et le panneau "Décisions d'attribution" contient "10 / 10"

  Scénario: Le personnel peut télécharger ou générer les décisions d'attribution manquantes
    Quand je clique sur "Éditer les décisions d'attribution"
    Et que la génération des décisions d'attribution manquantes est complètement finie
    Et que l'API SYGNE renvoie 10 nouveaux élèves pour l'établissement "DINUM"
    Et que les élèves de l'établissement "DINUM" sont rafraîchis
    Quand je me rends sur la page d'accueil
    Alors la page contient "Éditer 10 décisions d'attribution manquantes"
    Et la page contient "Télécharger les décisions d'attribution existantes"
