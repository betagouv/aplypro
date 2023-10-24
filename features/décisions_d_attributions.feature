# language: fr

Fonctionnalité: Le personnel de direction peut éditer les décisions d'attribution
  Contexte:
    Sachant que l'API SYGNE renvoie une liste d'élèves
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"
    Et que je passe l'écran d'accueil
    Alors le panel de décision d'attribution contient "0 / 1"

  Scénario: Le personnel de direction peut lancer l'édition des décisions d'attribution
    Quand je clique sur "Éditer les décisions d'attribution"
    Alors la page contient "Édition des décisions d'attribution en cours"
    Quand toutes les tâches de fond sont terminées
    Et que je rafraîchis la page
    Alors la page contient "Télécharger l'ensemble des décisions d'attribution"
    Et le panel de décision d'attribution contient "1 / 1"
