# language: fr

# Note : les IDEs et leurs plugins Cucumber sont censés pouvoir gérer
# l'internationalisation et donc les mots-clés en français aussi.

Fonctionnalité: Accueil d'un personnel de direction sur l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et qu'il y a une élève "Marie Curie" au sein de la classe "2NDEB" pour une formation "Développement"

  Scénario: Le personnel de direction voit un écran d'accueil la première fois
    Sachant que je peux voir l'écran d'accueil
    Quand je clique sur "Continuer"
    Alors la page contient "Année scolaire"

  Scénario: Le personnel de direction voit tous les menus
    Quand je clique sur "Continuer"
    Alors la page contient "Paiements"
    Et la page contient "Gestion des accès"

  Scénario: Le personnel de direction voit toutes les actions de directeur
    Quand je clique sur "Continuer"
    Alors le panneau "Décisions d'attribution" contient "Éditer la décision d'attribution manquante"
    Alors le panneau "Demandes de paiements des PFMPs" contient "Consulter et gérer les envois en paiement"

  Scénario: Le personnel voit un aperçu des données sur la page d'accueil
    Quand je clique sur "Continuer"
    Et que je renseigne les coordonnées bancaires de l'élève "Marie Curie" de la classe "2NDEB"
    Et que je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient "0 / 1"
    Et le panneau "Coordonnées bancaires" contient "1 / 1"
    Et l'indicateur de PFMP "À compléter" affiche 0
    Et l'indicateur de PFMP "Saisies à valider" affiche 0
    Et l'indicateur de PFMP "Validées" affiche 0
    Et l'indicateur de demandes de paiements "En attente" affiche 0
    Et l'indicateur de demandes de paiements "En traitement" affiche 0
    Et l'indicateur de demandes de paiements "Paiements envoyés" affiche 0

  Scénario: Le personnel de direction voit le nom du directeur confirmé existant dans le panel de décision d'attribution
    Sachant que mon établissement a un directeur confirmé nommé "Jean Dupuis"
    Et que je me rends sur la page d'accueil
    Alors le panneau "Décisions d'attribution" contient "Vous remplacerez Jean Dupuis"

  Scénario: Le personnel ne voit pas de bandeau de support si son établissement n'est pas enlicé
    Quand je rafraîchis la page
    Alors la page ne contient pas "faites-nous part de vos retours"

  Scénario: Le personnel voit les scolarités inactives dans les données de la page d'accueil
    Quand il y a un élève avec une scolarité fermée qui a une PFMP
    Et que je me rends sur la page d'accueil
    Alors l'indicateur de PFMP "À compléter" affiche 1
