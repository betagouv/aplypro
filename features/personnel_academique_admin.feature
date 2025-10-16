# language: fr

Fonctionnalité: Navigation pour les administrateurs académiques

  Contexte:
    Sachant qu'il existe un établissement avec le code académie "06"
    Et qu'il existe un établissement avec le code académie "14"
    Et qu'il existe un établissement avec le code académie "16"

  Scénario: Un personnel académique non-admin ne voit pas les liens statistiques et outils
    Sachant que je suis un personnel académique de "06"
    Et que je me connecte en tant que personnel académique
    Alors la page contient "Académie 06"
    Et la page ne contient pas "Statistiques"
    Et la page ne contient pas "Outils"

  Scénario: Un personnel académique admin voit les liens statistiques et outils
    Sachant que je suis un personnel académique administrateur
    Et que je me connecte en tant que personnel académique
    Et que je sélectionne "06" pour "Académie"
    Et que je clique sur "Continuez avec cette académie"
    Alors la page contient "Statistiques"
    Et la page contient "Outils"

  Scénario: Un personnel académique admin a accès à toutes les académies
    Sachant que je suis un personnel académique administrateur
    Quand je me connecte en tant que personnel académique
    Alors la page contient "Veuillez sélectionner l'académie que vous désirez piloter"
    Et je devrais voir l'académie "06" dans les options
    Et je devrais voir l'académie "14" dans les options
    Et je devrais voir l'académie "16" dans les options
    Quand je sélectionne "06" pour "Académie"
    Et que je clique sur "Continuez avec cette académie"
    Alors la page contient "Académie 06"
    Quand je clique sur "Changer d'académie"
    Et que je sélectionne "14" pour "Académie"
    Et que je clique sur "Continuez avec cette académie"
    Alors la page contient "Académie 14"
