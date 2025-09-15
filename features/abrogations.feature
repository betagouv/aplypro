# language: fr
Fonctionnalité: Gestion des abrogations
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que l'API SYGNE renvoie 10 élèves dans une classe "1MELEC" dont "Curie Marie" pour l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et que toutes les tâches de fond sont terminées
    Lorsque je consulte la liste des décisions d'attributions abrogeables

  Scénario: Aucune décision d'attribution à abroger si les conditions ne sont pas réunies
    Alors la page contient "Il n'y a aucune décision d'attribution à abroger pour le moment."

  Scénario: Seul le directeur peut abroger les décisions d'attribution
    Sachant que l'élève "Curie Marie" a une scolarité fermée
    Et que l'élève "Curie Marie" a une décision d'attribution
    Et que l'élève "Curie Marie" a une scolarité plus récente pour l'année scolaire 2024
    Lorsque je me déconnecte
    Et que je suis un personnel MENJ de l'établissement "DINUM" avec une délégation DELEG-CE pour APLyPro
    Lorsque je me connecte en tant que personnel MENJ
    Et que toutes les tâches de fond sont terminées
    Lorsque je consulte la liste des décisions d'attributions abrogeables
    Alors la page contient un bouton "Abroger la décision d'attribution" désactivé

  Scénario: La décision d'attribution est abrogeable si les conditions sont réunies
    Sachant que l'élève "Curie Marie" a une scolarité fermée
    Et que l'élève "Curie Marie" a une décision d'attribution
    Et que l'élève "Curie Marie" a une scolarité plus récente pour l'année scolaire 2024
    Et que je rafraîchis la page
    Alors la page contient "Année scolaire 2024 - 2025"
    Et la page contient "Curie Marie"
    Lorsque je clique sur "Abroger la décision d'attribution"
    Alors la page contient "Êtes-vous certain(e) de vouloir abroger cette décision d'attribution ?"
    Lorsque je coche la case de responsable légal
    Et que je clique sur "Confirmer l'abrogation"
    Alors la page contient "Télécharger l'abrogation"
    Lorsque je consulte la liste des décisions d'attributions abrogeables
    Alors la page ne contient pas "Année scolaire 2024 - 2025"
    Et la page ne contient pas "Curie Marie"
