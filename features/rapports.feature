# language: fr

Fonctionnalité: Pagination de la page des rapports

  Contexte:
    Sachant qu'il existe un établissement avec le code académie "06"
    Et que je suis un personnel académique de "06"
    Et que je me connecte en tant que personnel académique

  Scénario: La page des rapports s'affiche sans pagination avec peu de rapports
    Sachant qu'il existe 3 rapports
    Quand je me rends sur la page des rapports
    Alors la page contient "Historique des rapports"
    Et la page ne contient pas de lien vers la page de pagination 2

  Scénario: La pagination s'affiche quand le nombre de rapports dépasse la limite par page
    Sachant qu'il existe 26 rapports
    Quand je me rends sur la page des rapports
    Alors la page contient "Historique des rapports"
    Et la page contient un lien vers la page de pagination 2

  Scénario: On peut naviguer vers la page suivante
    Sachant qu'il existe 26 rapports
    Quand je me rends sur la page des rapports
    Et que je clique sur le lien de pagination 2
    Alors l'URL contient "page=2"
