# language: fr

Fonctionnalité: Le personnel ASP consulte des dossiers

  Contexte:
    Sachant qu'une PFMP a été saisie, validée et envoyée en paiement pour l'élève "Marie Curie"
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
    Sachant que le numéro administratif de "Marie Curie" est "DOSS3000"
    Quand je remplis "Numéro de décision d'attribution" avec "ENPUDOSS3000"
    Et que je clique sur "Rechercher"
    Alors la page contient "ENPUDOSS3000"
    Et la page contient "3 jours x 10 € par jour = 30 €"

  Scénario: Le personnel ASP entre un numéro de dossier ASP existant
    Sachant que le numéro de dossier ASP de "Marie Curie" est "12345"
    Quand je remplis "Numéro de décision d'attribution" avec "12345"
    Et que je clique sur "Rechercher"
    Alors la page contient "12345"
    Et la page contient "3 jours x 10 € par jour = 30 €"

  Scénario: Le personnel ASP entre un numéro de prestation dossier ASP existant
    Sachant que le numéro de prestation dossier ASP de la PFMP de "Marie Curie" est "10004"
    Quand je remplis "Numéro de décision d'attribution" avec "10004"
    Et que je clique sur "Rechercher"
    Alors la page contient "10004"
    Et la page contient "3 jours x 10 € par jour = 30 €"

  Scénario: Le personnel ASP n'a pas accès à l'interface principale
    Quand je me rends sur la page d'accueil
    Alors le titre de la page contient "Rechercher un dossier"
    Et la page ne contient pas "Élèves"
    Et la page ne contient pas "Envoyer en paiement"
