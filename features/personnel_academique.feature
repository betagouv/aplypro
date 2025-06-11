# language: fr

Fonctionnalité: Gestion du personnel académique
  Contexte:
    Sachant que je suis un personnel académique de "06"
    Et que je me connecte en tant que personnel académique

  Scénario: Le personnel académique a accès à la page d'accueil
    Alors la page contient "Académie 06"

  Scénario: Le personnel académique a accès à plusieurs académies
    Sachant que je me déconnecte
    Et que je suis un personnel académique des académies de "11, 16"
    Quand je me connecte en tant que personnel académique
    Et que je sélectionne "11" pour "Académie"
    Et que je clique sur "Continuez avec cette académie"
    Alors la page contient "Académie 11"
    Alors la page ne contient pas "Rechercher un élève"
    Quand je clique sur "Changer d'académie"
    Et que je sélectionne "16" pour "Académie"
    Et que je clique sur "Continuez avec cette académie"
    Alors la page contient "Académie 16"

  Scénario: Le personnel académique est redirigé vers la page de connexion académique en cas d'erreur de connexion
    Sachant que je me déconnecte
    Et que je me rend sur la page d'accueil du personnel académique
    Alors la page contient "Vous devez vous connecter ou vous enregistrer pour continuer."

  Scénario: Le personnel académique ne peut pas accéder aux pages pour l'ASP ou les chefs d'établissement
    Quand je me rends sur la page d'accueil
    Alors la page contient "Vous devez vous connecter ou vous enregistrer pour continuer."
    Quand je me rend sur la page de recherche de dossier
    Alors la page contient "Vous devez vous connecter ou vous enregistrer pour continuer."

  Scénario: Le personnel académique n'est pas encore validé
    Sachant que je me déconnecte
    Et que je suis un personnel académique sans validation
    Et que je me connecte en tant que personnel académique
    Alors la page contient "Erreur d'authentification"

  Scénario: Le personnel académique peut voir la liste des directeurs
    Lorsque je me rends sur la page d'accueil
    Quand je clique sur "Utilisateurs"
    Alors la page contient "Directeurs - Académie 06"
