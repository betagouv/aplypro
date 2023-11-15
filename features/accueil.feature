# language: fr

# Note : les IDEs et leurs plugins Cucumber sont censés pouvoir gérer
# l'internationalisation et donc les mots-clés en français aussi.

Fonctionnalité: Accueil sur l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"

  Scénario: Le personnel de direction voit un écran d'accueil la première fois
    Quand je n'ai pas encore vu l'écran d'accueil
    Et que je rafraîchis la page
    Alors la page contient "Bienvenue sur APLyPro"
    Et la page ne contient pas "Année scolaire"
    Quand je clique sur "Continuer"
    Alors la page contient "Année scolaire"

  Scénario: Le personnel voit un aperçu des données sur la page d'accueil
    Quand je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient un compteur à "0 / 1"
    Et le panneau "Coordonnées bancaires" contient un compteur à "1 / 1"
    Et le panneau "Périodes de formation en milieu professionnel" contient un compteur à "0"
    Et le panneau "PFMP validées" contient un compteur à "0"

  Scénario: Le personnel voit un bandeau de support si son établissement est enlicé
    Quand l'établissement "DINUM" fait parti des établissments soutenus directement
    Et que je rafraîchis la page
    Alors la page contient "faites-nous part de vos retours"

  Scénario: Le personnel ne voit pas de bandeau de support si son établissement n'est pas enlicé
    Quand je rafraîchis la page
    Alors la page ne contient pas "faites-nous part de vos retours"
