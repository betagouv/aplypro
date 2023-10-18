# language: fr

# Note : les IDEs et leurs plugins Cucumber sont censés pouvoir gérer
# l'internationalisation et donc les mots-clés en français aussi.

Fonctionnalité: Accueil sur l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et qu'il y a une élève "Marie Curie" au sein de la classe "3EMEB" pour une formation "Développement"

  Scénario: Le personnel de direction voit un écran d'accueil la première fois
    Quand je n'ai pas encore vu l'écran d'accueil
    Et que je rafraîchis la page
    Alors la page contient "Bienvenue sur APLyPro"
    Et la page ne contient pas "Liste des classes"
    Quand je clique sur "Continuer"
    Alors la page contient "Liste des classes"
