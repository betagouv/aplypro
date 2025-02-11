# language: fr

Fonctionnalité: Gestion du personnel académique
  Contexte:
    Sachant que je suis un personnel académique de l'établissement "DINUM"
    Et que je me connecte en tant que personnel académique

  Scénario: Le personnel académique a accès à la page d'accueil
    Alors la page contient "Bonjour"

  Scénario: Le personnel académique est redirigé vers la page de connexion académique en cas d'erreur de connexion
    Sachant que je me déconnecte
    Et que je me rend sur la page d'accueil du personnel académique
    Alors la page contient "Vous devez vous connecter ou vous enregistrer pour continuer."
