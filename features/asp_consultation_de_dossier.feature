# language: fr

Fonctionnalité: Le personnel ASP consulte des dossiers
  Contexte:
    Sachant qu'une PFMP de 30 euros a été saisie, validée et envoyée en paiement pour l'élève "Marie Curie"
    Et que je suis un agent de l'ASP
    Et que je me connecte au portail ASP
    Et que je me rend sur la page de recherche de dossier

  Scénario: Le personnel ASP a accès à la page de recherche de dossier
    Alors la page contient "Entrez un numéro de décision d'attribution pour lancer une recherche"

  Scénario: Le personnel ASP entre un numéro de décision d'attribution inexistant
    Quand je remplis "Numéro de décision d'attribution" avec "test"
    Et que je clique sur "Rechercher"
    Alors la page contient "Aucune décision d'attribution trouvée"

  Scénario: Le personnel ASP entre un numéro de décision d'attribution existant
    Sachant que le numéro administratif de "Marie Curie" est "THEDOSS"
    Et que je remplis "Numéro de décision d'attribution" avec "ENPUTHEDOSS20240"
    Quand je clique sur "Rechercher"
    Quand je clique sur "ENPUTHEDOSS20240"
    Alors la page contient "3 jours x 10 € par jour = 30 €"
    Et la page contient "IBAN"

  Scénario: Le personnel ASP n'a pas accès à l'interface principale
    Quand je me rends sur la page d'accueil
    Alors le titre de la page contient "Recherche d'un dossier"
    Et la page ne contient pas "Classes"
    Et la page ne contient pas "Envoyer en paiement"

  Scénario: Le personnel ASP est redirigé vers la page de connexion ASP en cas d'erreur de connexion
    Sachant que je me déconnecte
    Et que je suis un agent de l'ASP avec l'email "foobar@gmail.com"
    Quand je me connecte au portail ASP
    Alors la page contient "Erreur lors du traitement de votre profil"
    Et la page contient "Vous êtes un agent de l'ASP"
