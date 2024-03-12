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
    Alors la page contient "Bienvenue sur APLyPro"

  Scénario: Je ne peux me connecter à l'application si mon email n'a pas été autorisé
    Sachant que je suis un personnel MENJ de l'établissement "DINUM" avec l'email "louis.pasteur@education.gouv.fr"
    Lorsque je me connecte en tant que personnel MENJ
    Alors la page affiche une erreur d'authentification

  Scénario: Je ne peux pas gérer les accès en tant qu'invité
    Lorsque je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors la page ne contient pas "Gestion des accès"
    Et la page ne contient pas "Envoyer en paiement"

  Scénario: Je ne voit pas toutes les actions de directeur
    Lorsque je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil
    Alors le panneau "Décisions d'attribution" ne contient pas "Éditer les décisions d'attribution"
    Alors le panneau "Demandes de paiements des PFMPs" ne contient pas "Valider des PFMPs à envoyer en paiement"

  Scénario: Je ne peux plus me connecter à l'application en tant qu'invité si mon accès a été supprimé
    Lorsque je me connecte en tant que personnel MENJ
    Et que je me déconnecte
    Et que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je consulte la liste des invitations
    Et que je clique sur "Retirer l'accès"
    Et que je me déconnecte
    Quand je suis un personnel MENJ de l'établissement "DINUM" avec l'email "marie.curie@education.gouv.fr"
    Et que je me connecte en tant que personnel MENJ
    Alors la page affiche une erreur d'authentification
