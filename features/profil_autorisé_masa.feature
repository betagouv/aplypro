# language: fr

Fonctionnalité: Gestion des accès à l'application
  Contexte:
    Sachant que je suis un personnel MASA directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MASA
    Et que je passe l'écran d'accueil
    Et j'autorise "marie.curie@educagri.fr" à rejoindre l'application
    Et que je me déconnecte
    Quand je suis un personnel MASA de l'établissement "DINUM" avec l'email "marie.curie@educagri.fr"

  Scénario: Je peux me connecter à l'application si mon email a été autorisé
    Lorsque je me connecte en tant que personnel MASA
    Alors la page contient "Bienvenue sur APLyPro"

  Scénario: Je ne peux me connecter à l'application si mon email n'a pas été autorisé
    Sachant que je suis un personnel MASA de l'établissement "DINUM" avec l'email "louis.pasteur@educagri.fr"
    Lorsque je me connecte en tant que personnel MASA
    Alors la page affiche une erreur d'authentification

  Scénario: Je ne peux pas gérer les accès en tant qu'invité
    Lorsque je me connecte en tant que personnel MASA
    Et que je passe l'écran d'accueil
    Alors la page ne contient pas "Gestion des accès"

  Scénario: Je ne peux plus me connecter à l'application en tant qu'invité si mon accès a été supprimé
    Lorsque je me connecte en tant que personnel MASA
    Et que je me déconnecte
    Et que je suis un personnel MASA directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MASA
    Et que je consulte la liste des invitations
    Et que je clique sur "Retirer l'accès"
    Et que je me déconnecte
    Quand je suis un personnel MASA de l'établissement "DINUM" avec l'email "marie.curie@educagri.fr"
    Et que je me connecte en tant que personnel MASA
    Alors la page affiche une erreur d'authentification
