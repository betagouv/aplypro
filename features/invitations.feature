# language: fr

Fonctionnalité: Gestion des accès à l'application
  Contexte:
    Sachant que je suis un personnel MENJ directeur de l'établissement "DINUM"
    Et que je me connecte en tant que personnel MENJ
    Et que je passe l'écran d'accueil

  Scénario: Je peux inviter une nouvelle personne sur l'application
    Lorsque j'autorise "marie.curie@education.gouv.fr" à rejoindre l'application
    Lorsque je consulte la liste des invitations
    Alors la page contient "marie.curie@education.gouv.fr"

  Scénario: Je ne peux pas inviter que des emails académiques
    Lorsque j'autorise "marie.curie@gmail.com" à rejoindre l'application
    Alors la page contient "seuls les emails académiques"

  Scénario: Je peux supprimer une invitation
    Lorsque j'autorise "marie.curie@education.gouv.fr" à rejoindre l'application
    Et que je consulte la liste des invitations
    Et que je clique sur "Retirer l'accès"
    Alors la page contient "marie.curie@education.gouv.fr n'est plus autorisé à accéder à APLyPro"
