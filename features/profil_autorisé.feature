# language: fr

Fonctionnalité: Gestion des accès à l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et j'autorise "marie.curie@education.gouv.fr" à rejoindre l'application
    Et que je me déconnecte
    Quand je suis un personnel MENJ de l'établissement "DINUM" avec l'email "marie.curie@education.gouv.fr"

  Scénario: Je peux me connecter à l'application si mon email a été autorisé
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page contient "Bienvenue sur Aplypro"

  Scénario: Je ne peux me connecter à l'application si mon email n'a pas été autorisé
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec l'email "louis.pasteur@education.gouv.fr"
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page contient "adresse e-mail n'est pas reconnue"

  Scénario: Je ne peux pas gérer les accès en tant qu'invité
    Lorsque je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors la page ne contient pas "Gestion des accès"
