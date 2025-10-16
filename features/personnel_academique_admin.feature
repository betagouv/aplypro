# language: fr

Fonctionnalité: Navigation pour les administrateurs académiques

  Scénario: Un personnel académique non-admin ne voit pas les liens statistiques et outils
    Sachant que je suis un personnel académique de "06"
    Et que je me connecte en tant que personnel académique
    Alors la page contient "Académie 06"
    Et la page ne contient pas "Statistiques"
    Et la page ne contient pas "Outils"

  Scénario: Un personnel académique admin voit les liens statistiques et outils
    Sachant que je suis un personnel académique administrateur
    Et que je me connecte en tant que personnel académique
    Alors la page contient "Statistiques"
    Et la page contient "Outils"
