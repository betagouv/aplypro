# language: fr

Fonctionnalité: Le personnel de direction peut éditer les décisions d'attribution
  Contexte:
    Sachant que l'API SYGNE renvoie 10 élèves en "1MELEC" dont l'INE "test" pour l'établissement "DINUM"
    Et que l'API SYGNE peut fournir les informations complètes des étudiants
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Et je rafraîchis la page

  Scénario: Le personnel de direction peut voir le nombre de décisions à générer
    Alors le panneau "Décisions d'attribution" contient "0 / 10"

  Scénario: Le personnel de direction peut lancer l'édition des décisions d'attribution
    Quand je clique sur "Éditer les décisions d'attribution"
    Alors la page contient "Édition des décisions d'attribution en cours"
    Quand toutes les tâches de fond sont terminées
    Et que je rafraîchis la page
    Alors la page contient "Télécharger l'ensemble des décisions d'attribution"
    Et le panneau "Décisions d'attribution" contient "10 / 10"
