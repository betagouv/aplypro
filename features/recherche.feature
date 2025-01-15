# language: fr
Fonctionnalité: Recherche
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Jüãn-Frânçois Mîchäèl-d'Estaing" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées

  Scénario: Le personnel veut rechercher un élève
    Quand je recherche l'élève "a"
    Alors la page contient "Recherche d'un élève"
    Et la page contient "résultats trouvés pour la recherche : a"
    Quand je recherche l'élève "XRTEZEDE"
    Alors la page contient "Aucun résultat trouvé pour la recherche : XRTEZEDE"
    Quand je recherche l'élève "juan francois michael dest"
    Alors la page contient "Jüãn-Frânçois Mîchäèl-d'Estaing"
