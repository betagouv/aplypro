# language: fr

Fonctionnalité: Gestion des accès à l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Et j'invite "marie.curie@education.gouv.fr" à rejoindre l'application
    Et que je me déconnecte
    Quand je suis un personnel MENJ de l'établissement "DINUM" avec l'email "marie.curie@education.gouv.fr"

  Scénario: Je peux me connecter à l'application si mon profil a été délégué
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page contient "Bienvenue sur Aplypro"

  Scénario: Je ne peux me connecter à l'application si mon profil n'a pas été délégué
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec l'email "louis.pasteur@education.gouv.fr"
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page contient "e-mail n'est pas connue"
